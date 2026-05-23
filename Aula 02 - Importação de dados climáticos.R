# =========================================================
# Workshop: Aplicando R no Mundo Real
# Aula 02 - IMPORTAÇÃO DE DADOS CLIMÁTICOS

###OS DADOS SÃO BAIXAODS DO SITE NASA POWER (power.larc.nasa.gov)
###Cheque o que os dados gerados (siglas) significam de fato

# =========================================================
# ---------------------------------------------------------
# Pacotes necessários
# ---------------------------------------------------------
# rstudioapi - Definir a trilha de dados automaticamente
# data.table - Exportar e importar dados para o R
required_packages <- c("rstudioapi", "data.table")

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

# ---------------------------------------------------------
# LEITURA DE DADOS CLIMÁTICOS 
# ---------------------------------------------------------
###Aqui é para carregar as funções direto do github
###dos autores do pacote (que ainda não foi publicado)
source('https://raw.githubusercontent.com/allogamous/EnvRtype/master/R/AtmosphericPAram.R')
source('https://raw.githubusercontent.com/allogamous/EnvRtype/master/R/SradPARAM.R')
source('https://raw.githubusercontent.com/allogamous/EnvRtype/master/R/SupportFUnction.R')
source('https://raw.githubusercontent.com/allogamous/EnvRtype/master/R/EnvTyping.R')
source('https://raw.githubusercontent.com/allogamous/EnvRtype/master/R/Wmatrix.R')
source('https://raw.githubusercontent.com/allogamous/EnvRtype/master/R/covfromraster.R')
source('https://raw.githubusercontent.com/allogamous/EnvRtype/master/R/envKernel.R')
source('https://raw.githubusercontent.com/allogamous/EnvRtype/master/R/gdd.R')
source('https://raw.githubusercontent.com/allogamous/EnvRtype/master/R/getGEenriched.R')
source('https://raw.githubusercontent.com/allogamous/EnvRtype/master/R/get_weather_gis.R')
source('https://raw.githubusercontent.com/allogamous/EnvRtype/master/R/processWTH.R')
source('https://raw.githubusercontent.com/allogamous/EnvRtype/master/R/met_kernel_model.R')
source('https://raw.githubusercontent.com/allogamous/EnvRtype/master/R/summary_weather.R')
source('https://raw.githubusercontent.com/allogamous/EnvRtype/master/R/plot_panel.R')


###Nesse pacote, é preciso definir 5 argumentos
###local é o mais difícil pq tem que ser be específico
###1 - nome da cidade bem certinho, ex: Recife
###2 - underline e o código do estado, ex: PE
###3 - underline e o código do país, ex: BRA
### O código do país deve ser o internacional oficial
### O código de cada estado deve ser o oficial do País

# Criando as variáveis para rodas a função get_weather
local <- "Sorriso_MT_BRA"
lat = -12.5425
lon = -55.7211
data.inicial = as.Date("1/1/2010",format='%m/%d/%Y')
###Sys.date baixa os dados até a data atual
data.final = as.Date(Sys.Date(),format='%m/%d/%Y')
  
#a função get_weather tem 5 parâmetros
dados_climaticos <- get_weather(env.id = local, lat = lat,lon = lon,start.day = data.inicial,end.day = data.final)

#a função complete.cases retira linhas que não possuem dados/informação
dados_climaticos <- dados_climaticos[complete.cases(dados_climaticos),]
head(dados_climaticos)
fwrite(dados_climaticos, "Sorriso_MT_BRA.csv")

# =========================================================
# PRÓXIMOS PASSOS: AUTOMAÇÃO DE DADOS CLIMÁTICOS NO R
# =========================================================

# Depois que os alunos entenderem como importar dados climáticos
# manualmente usando latitude, longitude e período, o próximo passo
# é automatizar esse processo para várias localidades e anos.

# Em análises automáticas de dados climáticos, podemos criar scripts para:

# 1. Baixar dados climáticos automaticamente para várias cidades.
# 2. Baixar dados para diferentes coordenadas geográficas.
# 3. Criar loops para centenas de ambientes agrícolas.
# 4. Trabalhar com diferentes períodos da safra.
# 5. Atualizar automaticamente os dados climáticos diariamente.
# 6. Integrar clima com dados fenotípicos e genotípicos.
# 7. Calcular variáveis ambientais automaticamente.
# 8. Criar matrizes ambientais para modelos de machine learning.
# 9. Identificar estresse térmico, hídrico e radiação solar.
# 10. Gerar gráficos climáticos automaticamente.
# 11. Criar mapas climáticos.
# 12. Integrar clima com imagens de satélite.
# 13. Construir modelos preditivos agrícolas.
# 14. Criar dashboards interativos para monitoramento climático.
# 15. Automatizar relatórios climáticos em HTML, Word ou PDF usando Quarto.

# =========================================================
# EXEMPLO DE AUTOMAÇÃO FUTURA
# =========================================================

# O aluno poderia informar apenas:

# local <- "Sorriso_MT_BRA"
# lat <- -12.5425
# lon <- -55.7211
# data.inicial <- "2010-01-01"
# data.final <- "2025-12-31"

# O script automaticamente:
#   conecta à base climática
#   baixa os dados meteorológicos
#   organiza as variáveis ambientais
#   remove dados faltantes
#   salva os resultados
#   gera gráficos climáticos
#   exporta tabelas finais

# =========================================================
# EXEMPLOS DE VARIÁVEIS CLIMÁTICAS IMPORTANTES
# =========================================================

# Temperatura mínima
# Temperatura máxima
# Temperatura média
# Precipitação
# Umidade relativa
# Radiação solar
# Velocidade do vento
# Evapotranspiração
# Graus-dia
# Déficit hídrico

# =========================================================
# EXEMPLOS DE APLICAÇÕES REAIS
# =========================================================

# 1. Monitoramento agrícola.
# 2. Zoneamento agrícola.
# 3. Modelos de produtividade.
# 4. Predição de doenças.
# 5. Predição de insetos.
# 6. Machine learning agrícola.
# 7. Estudos de adaptação climática.
# 8. Modelagem GxE.
# 9. Agricultura de precisão.
# 10. Integração clima + genômica + satélite.

# =========================================================
# TRANSIÇÃO PARA ANÁLISES AVANÇADAS
# =========================================================

# Depois dessa etapa, os alunos estarão preparados para:

# - integrar clima com imagens de satélite;
# - construir modelos de machine learning;
# - trabalhar com dados espaciais;
# - automatizar pipelines ambientais;
# - desenvolver dashboards agrícolas;
# - criar sistemas de monitoramento agrícola em tempo real.

# Esse fluxo permite transformar consultas climáticas simples em
# sistemas automatizados de monitoramento ambiental e agrícola no R.