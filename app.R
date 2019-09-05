library(shiny)
library(shinydashboard)
library(leaflet)
library(leafem)
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
  EEZ <- sf::st_read("E:/Documents/SPU/SPUGEOM/br_EEZ.gml", 
                     crs = 4326) %>%
    sf::st_cast("GEOMETRYCOLLECTION") %>% 
    sf::st_collection_extract("POLYGON")
  
  IW <- sf::st_read("E:/Documents/SPU/SPUGEOM/br_aguas_internas.gml", 
                    crs = 4326) %>%
    sf::st_cast("GEOMETRYCOLLECTION") %>% 
    sf::st_collection_extract("POLYGON")
  
  TS <- sf::st_read("E:/Documents/SPU/SPUGEOM/br_mar_territorial.gml", 
                    crs = 4326) %>%
    sf::st_cast("GEOMETRYCOLLECTION") %>% 
    sf::st_collection_extract("POLYGON")
  
  CZ <- sf::st_read("E:/Documents/SPU/SPUGEOM/br_zona_contigua.gml", 
                    crs = 4326) %>%
    sf::st_cast("GEOMETRYCOLLECTION") %>% 
    sf::st_collection_extract("POLYGON")
  
  TRINDADE <- sf::st_read("E:/Documents/SPU/SPUGEOM/br_Trindade.gml", 
                          crs = 4326) %>%
    sf::st_cast("GEOMETRYCOLLECTION") %>% 
    sf::st_collection_extract("POLYGON")
  
  portos <- sf::st_read("portos.shp") %>%
    sf::st_transform(crs = 4326)
  
  certdisp <- sf::st_read("certdisp.shp") %>%
    sf::st_transform(crs = 4326)
    
  cessoes <- sf::st_read("cessoes.shp") %>%
    sf::st_transform(crs = 4326)
  
  ext <- extent(certdisp[1, ])
  
  output$mymap <- renderLeaflet({
    portos %>%   
      leaflet() %>%
      # Base Groups
      addTiles(group = "OSM (default)") %>%
      addProviderTiles(providers$OpenSeaMap, group = "OpenSea") %>%
      addProviderTiles(providers$Esri.OceanBasemap, group = "Esri Ocean") %>%
      addWMSTiles(baseUrl = "http://sigsc.sc.gov.br/sigserver/SIGSC/wms", 
                  layers = list("OrtoRGB-Landsat-2012"),
                  group = "SIG-SC") %>%
      addPolygons(data = EEZ, color = "green", group = "Zona Econômica Exclusiva") %>%
      addPolygons(data = IW, color = "royalblue", group = "Águas Internas") %>%
      addPolygons(data = TS, color = "navy", group = "Mar Territorial") %>%
      addPolygons(data = CZ, color = "blue4", group = "Zona Contígua") %>%
      addPolygons(data = TRINDADE, color = "blue4", group = "Trindade") %>%
      addPolygons(group = "Portos", color = "orange", stroke = TRUE, weight = 1) %>%
      addPolygons(data = certdisp, color = "blue", fillColor = "red", 
                  stroke = TRUE, weight = 1,
                  group = "Certidões de Disponibilidade") %>%
      addPolygons(data = cessoes, color = "red", fillColor = "red",
                  stroke = TRUE, weight = 1, 
                  group = "Cessões") %>%
      addScaleBar(position = 'bottomleft', options = list(imperial = FALSE)) %>%
      #addGraticule(interval = .05, style = list(weight = .2)) %>%
      addMiniMap(position = "topleft", zoomLevelOffset = -3, toggleDisplay = TRUE)  %>%
      # Layers control
      addLayersControl(baseGroups = c("OSM (default)", "OpenSea", "Esri Ocean", "SIG-SC"),
        overlayGroups = c("Cessões", "Certidões de Disponibilidade", "Portos", 
                          "Águas Internas", "Mar Territorial", "Zona Contígua",
                          "Zona Econômica Exclusiva", "Trindade"),
        options = layersControlOptions(collapsed = TRUE)
      ) %>%
      hideGroup("Cessões") %>%
      addHomeButton(ext = ext, layer.name = "DSP") %>%
      addMouseCoordinates() %>%
      addLogo("E:/Documents/SPUViz/SPU.jpg", src = "local", position = "bottomleft", 
              offset.x = 15, offset.y = 50)
  })
}

shinyApp(ui, server)

