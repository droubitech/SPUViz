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
                  query = "SELECT * FROM espacoaquatico.portos
                  WHERE municipio = 8319 OR municipio = 9985;") %>%
  st_transform(crs = 4326)
# Cessões no município de SFS e Itapoá
cessao <- st_read(conn, 
                  query = "SELECT * FROM espacoaquatico.cessao 
                  WHERE municipio = 8319 OR municipio = 9985;") %>%
  st_transform(crs = 4326)
# Certidões no município de SFS e Itapoá
certdisp <- st_read(conn, 
                    query = "SELECT * FROM espacoaquatico.certdisp
                  WHERE municipio = 8319 OR municipio = 9985;") %>%
  st_transform(crs = 4326)

## Escrever no disco
st_write(portos, "portos.shp")
st_write(certdisp, "certdisp.shp")
st_write(cessao, "cessoes.shp")
