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

## Escrever no disco
st_write(portos, "portos.geojson", delete_dsn = TRUE)
st_write(certdisp, "certdisp.geojson", delete_dsn = TRUE)
st_write(cessao, "cessoes.geojson", delete_dsn = TRUE)
