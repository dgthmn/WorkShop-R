# =========================================================
# Workshop: Aplicando R no Mundo Real
# Aula 04 - TRABALHANDO COM IMAGENS DE SATELITES NO R
# =========================================================
# ---------------------------------------------------------
# Pacotes necessários
# ---------------------------------------------------------
# rstudioapi - Definir a trilha de dados automaticamente
# data.table - Exportar e importar dados para o R
# terra - Trabalhar com imagens raster e dados espaciais
# sf - Criar e manipular shapefiles e objetos espaciais vetoriais
# RStoolbox - Ferramentas para processamento de imagens de satélite

required_packages <- c("rstudioapi", "terra", "data.table", "sf", "RStoolbox")

for (pkg in required_packages) {
  if (!require(pkg, character.only = TRUE)) {
    install.packages(pkg)
    library(pkg, character.only = TRUE)
  }
}

# Definir o diretório de trabalho automaticamente via rstudioapi
setwd(dirname(rstudioapi::getActiveDocumentContext()$path))

# Verificar o diretório de trabalho atual
print(paste("Diretório de trabalho atual:", getwd()))

# terra trabalha com dados raster e vetoriais.
# Imagens de satélite são dados raster, ou seja,
# imagens formadas por pixels com valores numéricos.

# =========================================================
# 1) BAIXAR AS IMAGENS
# =========================================================
# 1. Acesse o Copernicus Browser https://browser.dataspace.copernicus.eu/?utm_source=chatgpt.com.
# 2. Crie uma conta gratuita.
# 3. Pesquise sua área de interesse.
# 4. Escolha uma data com pouca nuvem.
# 5. Selecione Sentinel-2 L2A.
# 6. Baixe as bandas, por exemplo:
#    B02 = azul
#    B03 = verde
#    B04 = vermelho
#    B08 = infravermelho próximo

# =========================================================
# 2) DEFINIR A PASTA DE TRABALHO
# =========================================================

# Coloque aqui o caminho da pasta onde estão as bandas da imagem.
# Exemplo:
setwd("C:\\Users\\leonardo\\OneDrive\\Documentos Analise\\R no Mundo Real Dados Climáticos, APIs, Satélites e Machine Learning\\Browser_images")

# Verificar arquivos disponíveis na pasta
list.files()

# =========================================================
# 3) IMPORTAR AS BANDAS DA IMAGEM
# =========================================================

# Exemplo com imagem Sentinel-2 ou Landsat.
# Cada arquivo representa uma banda espectral.

blue  <- rast("B02.tiff")   # Banda azul
green <- rast("B03.tiff")   # Banda verde
red   <- rast("B04.tiff")   # Banda vermelha
nir   <- rast("B08.tiff")   # Infravermelho próximo

# Visualizar informações básicas
blue
green
red
nir

# =========================================================
# 4) EMPILHAR AS BANDAS
# =========================================================

# Criar um objeto com várias bandas juntas
img <- c(blue, green, red, nir)

# Nomear as bandas
names(img) <- c("Blue", "Green", "Red", "NIR")

# Verificar o objeto
img

# =========================================================
# 5) VISUALIZAR BANDAS INDIVIDUAIS
# =========================================================

plot(red, main = "Banda Vermelha")
plot(green, main = "Banda Verde")
plot(blue, main = "Banda Azul")
plot(nir, main = "Banda Infravermelho Próximo")

# =========================================================
# 6) CRIAR COMPOSIÇÕES COLORIDAS
# =========================================================

# Composição RGB verdadeira
# Red = banda vermelha
# Green = banda verde
# Blue = banda azul

plotRGB(img,
        r = 3,
        g = 2,
        b = 1,
        stretch = "lin",
        main = "Composição RGB Verdadeira")

# Composição falsa cor
# Muito usada para vegetação
# NIR aparece em vermelho

plotRGB(img,
        r = 4,
        g = 3,
        b = 2,
        stretch = "lin",
        main = "Composição Falsa Cor")


# =========================================================
# 7) CALCULAR O NDVI
# =========================================================

# NDVI = (NIR - Red) / (NIR + Red)
# Valores próximos de 1 indicam vegetação mais vigorosa.
# Valores próximos de 0 indicam solo exposto ou vegetação fraca.
# Valores negativos podem indicar água, sombra ou áreas não vegetadas.

ndvi <- (nir - red) / (nir + red)

plot(ndvi,
     main = "NDVI - Índice de Vegetação")

# =========================================================
# 8) SALVAR O NDVI
# =========================================================

writeRaster(ndvi,
            "NDVI_resultado.tif",
            overwrite = TRUE)

# =========================================================
# 9) CRIAR UMA ÁREA DE INTERESSE MANUALMENTE
# =========================================================

# Primeiro, vamos visualizar a imagem
plotRGB(img,
        r = 3,
        g = 2,
        b = 1,
        stretch = "lin",
        main = "Clique ao redor da área agrícola")

# Agora clique nos cantos da área agrícola.
# Clique em volta do talhão, formando um polígono.
# Quando terminar, pressione ESC.

pontos <- click(img, n = 10, xy = TRUE)

# Ver os pontos clicados
pontos

# Transformar pontos em matriz
coords <- as.matrix(pontos[, c("x", "y")])

# Fechar o polígono
coords <- rbind(coords, coords[1, ])

# Criar polígono com sf
poligono_sf <- st_polygon(list(coords))

# Criar objeto sf com o mesmo CRS da imagem
area_sf <- st_sf(
  id = 1,
  geometry = st_sfc(poligono_sf, crs = crs(img))
)

# Salvar como shapefile
st_write(area_sf,
         "area_agricola.shp",
         delete_layer = TRUE)

# =========================================================
# 10) RECORTAR A IMAGEM USANDO UMA ÁREA DE INTERESSE
# =========================================================

# A área de interesse pode ser um shapefile.
# Exemplo: limite de uma fazenda, talhão ou município.
area <- vect("area_agricola.shp")

# Verificar sistema de coordenadas
crs(img)
ext(img)
crs(area)

# Se necessário, reprojetar a área para o mesmo CRS da imagem
area <- project(area, crs(img))

# Recortar a imagem
img_crop <- crop(img, area)
img_mask <- mask(img_crop, area)

# Visualizar imagem recortada
plotRGB(img_mask,
        r = 3,
        g = 2,
        b = 1,
        stretch = "lin",
        main = "Imagem Recortada")


# Recortar o NDVI
ndvi_crop <- crop(ndvi, area)
ndvi_mask <- mask(ndvi_crop, area)

plot(ndvi_mask,
     main = "NDVI Recortado")

# =========================================================
# 11) EXTRAIR ESTATÍSTICAS DO NDVI
# =========================================================

# Média geral do NDVI na área
global(ndvi_mask, mean, na.rm = TRUE)

# Mínimo e máximo
global(ndvi_mask, min, na.rm = TRUE)
global(ndvi_mask, max, na.rm = TRUE)

# Desvio padrão
global(ndvi_mask, sd, na.rm = TRUE)

# =========================================================
# 11) CLASSIFICAR O NDVI EM CLASSES
# =========================================================

# Criar matriz de reclassificação:
# valores baixos, médios e altos de NDVI

classes <- matrix(c(
  -1.0, 0.6, 1,   # Baixo vigor
  0.6, 0.7, 2,   # Médio vigor
  0.7, 1.0, 3    # Alto vigor
), ncol = 3, byrow = TRUE)

ndvi_class <- classify(ndvi_mask, classes)

plot(ndvi_class,
     main = "Classes de NDVI")

# =========================================================
# 13) CALCULAR ÁREA DE CADA CLASSE
# =========================================================

# Cada pixel tem uma resolução espacial.
# Exemplo Sentinel-2: geralmente 10 m x 10 m = 100 m².
# 1 hectare = 10.000 m².

freq_classes <- freq(ndvi_class)

freq_classes$area_m2 <- freq_classes$count * 100
freq_classes$area_ha <- freq_classes$area_m2 / 10000

freq_classes

# =========================================================
# 14) EXPORTAR RESULTADOS
# =========================================================

writeRaster(ndvi_class,
            "NDVI_classes.tif",
            overwrite = TRUE)

write.csv(freq_classes,
          "area_classes_ndvi.csv",
          row.names = FALSE)


# =========================================================
# 15) CLASSIFICAÇÃO NÃO SUPERVISIONADA
# =========================================================

# Esta etapa separa a imagem em grupos de pixels semelhantes.
# É útil para identificar padrões sem informar previamente as classes.

set.seed(123)

class_unsup <- unsuperClass(img_mask,
                            nClasses = 4,
                            nSamples = 5000)

plot(class_unsup$map,
     main = "Classificação Não Supervisionada")


# Salvar classificação
writeRaster(class_unsup$map,
            "classificacao_nao_supervisionada.tif",
            overwrite = TRUE)


# =========================================================
# 16) PRÓXIMOS PASSOS: ANÁLISES AUTOMÁTICAS DE SATÉLITES NO R
# =========================================================

# Depois que os alunos entenderem o fluxo manual, o próximo passo é
# automatizar o processo para trabalhar com várias imagens, datas e áreas.

# Em análises automáticas, podemos criar scripts para:

# 1. Baixar imagens automaticamente de diferentes datas.
# 2. Filtrar imagens com baixa cobertura de nuvens.
# 3. Calcular NDVI para várias datas.
# 4. Recortar automaticamente a imagem usando shapefiles de talhões.
# 5. Criar mapas de vigor vegetal ao longo do tempo.
# 6. Comparar NDVI entre diferentes datas.
# 7. Identificar áreas com queda de vigor dentro da lavoura.
# 8. Gerar tabelas com média, mínimo, máximo e desvio padrão do NDVI.
# 9. Exportar mapas em TIFF, PNG ou PDF.
# 10. Criar relatórios automáticos em HTML, Word ou PDF usando Quarto.
# 11. Integrar imagens de satélite com dados climáticos.
# 12. Usar machine learning para classificar áreas agrícolas.
# 13. Criar dashboards interativos com Shiny.
# 14. Monitorar lavouras de forma contínua ao longo da safra.

# Exemplo de lógica futura:

# Para cada data:
#   abrir bandas
#   calcular NDVI
#   recortar área agrícola
#   extrair estatísticas
#   salvar mapa
#   salvar tabela

# Esse fluxo permite sair de uma análise manual para um sistema de
# monitoramento agrícola automatizado no R.