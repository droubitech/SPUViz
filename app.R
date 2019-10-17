library(shiny)
library(shinydashboard)
library(leaflet)
library(leafem)
library(leafpop)
library(raster)

r_colors <- rgb(t(col2rgb(colors()) / 255))
names(r_colors) <- colors()

#ui <- leafletOutput('mymap', height = "95vh")

ui <- bootstrapPage(
  tags$style(type = "text/css", "html, body {width:100%;height:100%}"),
  leafletOutput("mymap", width = "100%", height = "100%")
)

server <- function(input, output, session) {
  
  # Ler dados
  
  LPM_DEMARCADA <- sf::st_read("LPM_DEMARCADA.geojson")
  LPM_HOMOLOGADA <- sf::st_read("LPM_HOMOLOGADA.geojson")
  LPM_PRESUMIDA <- sf::st_read("LPM_PRESUMIDA.geojson")
  
  LLTM_DEMARCADA <- sf::st_read("LLTM_DEMARCADA.geojson")
  LLTM_HOMOLOGADA <- sf::st_read("LLTM_HOMOLOGADA.geojson")
  LLTM_PRESUMIDA <- sf::st_read("LLTM_PRESUMIDA.geojson")
  
  EEZ <- sf::st_read("br_EEZ.gml", 
                     crs = 4326) %>%
    sf::st_cast("GEOMETRYCOLLECTION") %>% 
    sf::st_collection_extract("POLYGON")
  
  IW <- sf::st_read("br_aguas_internas.gml", 
                    crs = 4326) %>%
    sf::st_cast("GEOMETRYCOLLECTION") %>% 
    sf::st_collection_extract("POLYGON")
  
  TS <- sf::st_read("br_mar_territorial.gml", 
                    crs = 4326) %>%
    sf::st_cast("GEOMETRYCOLLECTION") %>% 
    sf::st_collection_extract("POLYGON")
  
  CZ <- sf::st_read("br_zona_contigua.gml", 
                    crs = 4326) %>%
    sf::st_cast("GEOMETRYCOLLECTION") %>% 
    sf::st_collection_extract("POLYGON")
  
  TRINDADE <- sf::st_read("br_Trindade.gml", 
                          crs = 4326) %>%
    sf::st_cast("GEOMETRYCOLLECTION") %>% 
    sf::st_collection_extract("POLYGON")
  
  portos <- sf::st_read("portos.geojson") %>%
    sf::st_transform(crs = 4326)
  
  certdisp <- sf::st_read("certdisp.geojson") %>%
    sf::st_transform(crs = 4326)
    
  cessoes <- sf::st_read("cessoes.geojson") %>%
    sf::st_transform(crs = 4326)
  
  ext <- extent(matrix(c(-54, -29.5,  -48.3, -25.85), nrow=2))

  output$mymap <- renderLeaflet({
    portos %>%   
      leaflet() %>%
      # Base Groups
      addTiles(group = "OSM (default)") %>%
      addProviderTiles(providers$OpenSeaMap, group = "OpenSea") %>%
      addProviderTiles(providers$Esri.OceanBasemap, group = "Esri Ocean") %>%
      addProviderTiles(providers$Esri.WorldImagery, group = "Esri Imagery") %>%
      addWMSTiles(baseUrl = "http://sigsc.sc.gov.br/sigserver/SIGSC/wms", 
                  layers = list("OrtoRGB-Landsat-2012"),
                  group = "SIG-SC") %>%
      fitBounds(lng1 = -54, lng2 = -48.3, lat1 = -29.5, lat2 = -25.85) %>%
      addPolygons(data = EEZ, color = "green", group = "Zona Econômica Exclusiva") %>%
      addPolygons(data = IW, color = "royalblue", group = "Águas Internas") %>%
      addPolygons(data = TS, color = "navy", group = "Mar Territorial") %>%
      addPolygons(data = CZ, color = "blue4", group = "Zona Contígua") %>%
      addPolygons(data = TRINDADE, color = "blue4", group = "Trindade") %>%
      addPolygons(group = "Portos", color = "orange", stroke = TRUE, weight = 1,
                  popup = popupTable(portos)) %>%
      addPolygons(data = certdisp, color = "blue", fillColor = "red", 
                  stroke = TRUE, weight = 1,
                  group = "Certidões de Disponibilidade") %>%
      addPolygons(data = cessoes, color = "red", fillColor = "red",
                  stroke = TRUE, weight = 1, 
                  group = "Cessões") %>%
      ## Linhas de Preamar (LPM)
      addPolylines(data = LPM_DEMARCADA, color = "red", weight = 2,
                   dashArray = "20 10") %>%
      addPolylines(data = LPM_HOMOLOGADA, color = "red", weight = 2) %>%
      addPolylines(data = LPM_PRESUMIDA, color = "red", weight = 2, 
                   dashArray = "20 10", opacity = .30, label = "PRESUMIDA") %>%
      ## Linhas Limite de Terrenos de Marinha (LLTM)
      addPolylines(data = LLTM_DEMARCADA, color = "blue", weight = 2, 
                   dashArray = "20 10") %>%
      addPolylines(data = LLTM_HOMOLOGADA, color = "blue", weight = 2) %>%
      addPolylines(data = LLTM_PRESUMIDA, color = "blue", weight = 2, 
                   dashArray = "20 10", opacity = .30) %>%
      addScaleBar(position = 'bottomleft', options = list(imperial = FALSE)) %>%
      #addGraticule(interval = .05, style = list(weight = .2)) %>%
      addMiniMap(position = "topleft", zoomLevelOffset = -3, toggleDisplay = TRUE)  %>%
      # Layers control
      addLayersControl(baseGroups = c( "Esri Imagery", "SIG-SC", "OSM (default)", 
                                       "Esri Ocean", "OpenSea"),
        overlayGroups = c("Cessões", "Certidões de Disponibilidade", "Portos", 
                          "Águas Internas", "Mar Territorial", "Zona Contígua",
                          "Zona Econômica Exclusiva", "Trindade"),
        options = layersControlOptions(collapsed = TRUE)
      ) %>%
      hideGroup("Certidões de Disponibilidade") %>%
      addHomeButton(ext = ext, layer.name = "SC") %>%
      addMouseCoordinates() %>%
      addLogo("E:/Documents/SPUViz/SPU.jpg", src = "local", position = "bottomleft", 
              offset.x = 15, offset.y = 50)
  })
}

shinyApp(ui, server)

