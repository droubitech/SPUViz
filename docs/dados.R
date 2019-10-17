library(RPostgreSQL)
library(sf)
# 1. Conectar ao BDG
#
conn <- dbConnect("PostgreSQL",
                  host = "localhost", 
                  dbname = "spugeo",
                  user = "postgres", 
                  password = "campeao1")

# Portos no município de SFS e Itapoá
portos <- st_read(conn,
                  query = "SELECT * FROM espacoaquatico.portos;") %>%
  st_transform(crs = 4326)
# Cessões no município de SFS e Itapoá
cessao <- st_read(conn, 
                  query = "SELECT * FROM espacoaquatico.cessao;") %>%
  st_transform(crs = 4326)
# Certidões no município de SFS e Itapoá
certdisp <- st_read(conn, 
                    query = "SELECT * FROM espacoaquatico.certdisp;") %>%
  st_transform(crs = 4326)

# Ler dados
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


## Linhas de Marinha

LLTM_DEMARCADA_SAD69 <- st_read("LLTM_DEMARCADA_SAD69.geojson")
LLTM_DEMARCADA_SIRGAS2000 <- st_read("LLTM_DEMARCADA_SIRGAS2000.geojson")
LLTM_DEMARCADA <- rbind(LLTM_DEMARCADA_SAD69, LLTM_DEMARCADA_SIRGAS2000)
st_write(LLTM_DEMARCADA, "LLTM_DEMARCADA.geojson")
LLTM_HOMOLOGADA_SAD69 <- st_read("LLTM_HOMOLOGADA_SAD69.geojson")
LLTM_HOMOLOGADA_SIRGAS2000 <- st_read("LLTM_HOMOLOGADA_SIRGAS2000.geojson")
LLTM_HOMOLOGADA <- rbind(LLTM_HOMOLOGADA_SAD69, LLTM_HOMOLOGADA_SIRGAS2000)
st_write(LLTM_HOMOLOGADA, "LLTM_HOMOLOGADA.geojson")
LLTM_PRESUMIDA_SAD69 <- st_read("LLTM_PRESUMIDA_SAD69.geojson")
LLTM_PRESUMIDA_SIRGAS2000 <- st_read("LLTM_PRESUMIDA_SIRGAS2000.geojson")
LLTM_PRESUMIDA <- rbind(LLTM_PRESUMIDA_SAD69, LLTM_PRESUMIDA_SIRGAS2000)
st_write(LLTM_PRESUMIDA, "LLTM_PRESUMIDA.geojson")

LPM_DEMARCADA_SAD69 <- st_read("LPM_DEMARCADA_SAD69.geojson")
LPM_DEMARCADA_SIRGAS2000 <- st_read("LPM_DEMARCADA_SIRGAS2000.geojson")
LPM_DEMARCADA <- rbind(LPM_DEMARCADA_SAD69, LPM_DEMARCADA_SIRGAS2000)
st_write(LPM_DEMARCADA, "LPM_DEMARCADA.geojson")
LPM_HOMOLOGADA_SAD69 <- st_read("LPM_HOMOLOGADA_SAD69.geojson")
LPM_HOMOLOGADA_SIRGAS2000 <- st_read("LPM_HOMOLOGADA_SIRGAS2000.geojson")
LPM_HOMOLOGADA <- rbind(LPM_HOMOLOGADA_SAD69, LPM_HOMOLOGADA_SIRGAS2000)
st_write(LPM_HOMOLOGADA, "LPM_HOMOLOGADA.geojson")
LPM_PRESUMIDA_SAD69 <- st_read("LPM_PRESUMIDA_SAD69.geojson")
LPM_PRESUMIDA_SIRGAS2000 <- st_read("LPM_PRESUMIDA_SIRGAS2000.geojson")
LPM_PRESUMIDA <- rbind(LPM_PRESUMIDA_SAD69, LPM_PRESUMIDA_SIRGAS2000)
st_write(LPM_PRESUMIDA, "LPM_PRESUMIDA.geojson")

## Escrever no disco
st_write(portos, "portos.geojson", delete_dsn = TRUE)
st_write(certdisp, "certdisp.geojson", delete_dsn = TRUE)
st_write(cessao, "cessoes.geojson", delete_dsn = TRUE)
st_write(EEZ, "EEZ.geojson", delete_dsn = TRUE)
st_write(IW, "IW.geojson", delete_dsn = TRUE)
st_write(TS, "TS.geojson", delete_dsn = TRUE)
st_write(CZ, "CZ.geojson", delete_dsn = TRUE)
