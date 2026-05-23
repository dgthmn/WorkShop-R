# =========================================================
# Workshop: Aplicando R no Mundo Real
# Aula 03 - IMPORTAÇÃO DE DADOS DE SITES PÚBLICOS
# =========================================================
# ---------------------------------------------------------
# Pacotes necessários
# ---------------------------------------------------------
# rstudioapi - Definir a trilha de dados automaticamente
# data.table - Exportar e importar dados para o R
# dplyr - Manipulação de dados
# rvest - Acessar sites para web scrapping (Acessar dados)
required_packages <- c("rstudioapi", "dplyr", "data.table", "rvest")

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
# LEITURA DE DADOS DE EMPRESAS LISTADAS EM BOLSA
# ---------------------------------------------------------

# URL da página com informações sobre ações

###AQUI É MENOS AUTOMÁTICO QUE NAS OUTRAS AULAS, ENTÃO A 
###CURADORIA DO PESQUISADOR PRECISA SER BEM FEITA
### OU SEJA, É PRECISO VER O QUE FOI BAIXADO E IDENTIFICAR
### ERROS ANTES DE FAZER AS ANÁLISES


###PASSO 1 - ESCREVER O URL CORRETO
empresa <- "VALE3"
###O paste é para unir a parte padrão do url em aspas abaixo e
###e a página específica da emprea
url <- paste("https://www.fundamentus.com.br/detalhes.php?papel=",empresa, sep="")

###o passo acima é útil para baixar, por exemplo as infos de 
###duas empresas diferentes
# Ler a página
page <- read_html(url)
page

###PASSO 2 - TRAZER DADOS DE TEXTO
# Extrair o dividend yield (modifique o seletor conforme necessário)
dados_empresa <- page %>%
    html_nodes(".txt") %>%  # Insira o seletor correto
    html_text()
dados_empresa


###PASSO 3 - ORGANIZAR OS DADOS
###NÚMEROS VIERAM COM ',' DE SEPARADOR DECIMAL, ENTÃO 
###TRANSFORMO ISSO EM '.' COMO SEPARADOR
dados_empresa<-gsub(",", ".", dados_empresa)

###NÚMEROS POSSUEM /N ANTES COMO SEPARADOR DE LINHA
###E É PRECISO EXCLUIR ISSO OU 'substituir por nada'
dados_empresa<-gsub("\n", "", dados_empresa)

###ALGUNS NÚMEROS TEM UM '%' APÓS, E TB É PRECISO EXCLUIR
dados_empresa<-gsub("%", "", dados_empresa)

###CONSTRUIR O DATA FRAME
###dentro do parentese temos:
###Stock (é o nome que quero dar a coluna)
###=dados_empresa (de onde tiro a informação)
###[2] é a coluna dos dados originais que quero transformar
###em "Stock"
### a mesma coisa para todas as colunas que serão criadas no meu
###novo data frame
###por exemplo, nos dados originais "data_empresa", o setor 
###da empresa VALE3 está na linha 14, então eu coloco o nome
###que quero dar na minha nova tabela e adiciono a linha da
###da qual eu quero puxar os dados, nesse casa a [14]
# Construir a base de dados limpa
base_final<-data.frame(Stock=dados_empresa[2],
                       Name=dados_empresa[10],
                       Division=dados_empresa[14],
                       PL=dados_empresa[33],
                       PVP=dados_empresa[38],
                       DY=dados_empresa[68],
                       ROE=dados_empresa[70],
                       DBVP=dados_empresa[80],
                       CAGR=dados_empresa[83])
base_final
fwrite(base_final, "VALE3.csv")
dados_empresa


###TUDO AQUI FUNCIONA PARA QUALQUER SITE QUE CONTENHA DADOS PÚBLICOS


# =========================================================
# PRÓXIMOS PASSOS: AUTOMAÇÃO DE DADOS DE SITES PÚBLICOS NO R
# =========================================================

# Depois que os alunos entenderem como importar informações de um site
# usando web scraping, o próximo passo é automatizar esse processo para
# várias empresas, indicadores e períodos.

# Em análises automáticas com dados de sites públicos, podemos criar scripts para:

# 1. Buscar dados de várias empresas automaticamente.
# 2. Criar uma lista de códigos de ações, como VALE3, PETR4, BBAS3 e WEGE3.
# 3. Repetir o processo de leitura para cada empresa.
# 4. Extrair indicadores financeiros específicos.
# 5. Organizar os dados em uma única tabela.
# 6. Padronizar textos, números, porcentagens e separadores decimais.
# 7. Criar rankings de empresas com base em indicadores.
# 8. Comparar empresas do mesmo setor.
# 9. Filtrar empresas com melhores indicadores.
# 10. Exportar os resultados em CSV ou Excel.
# 11. Criar gráficos comparativos.
# 12. Criar relatórios automáticos com Quarto.
# 13. Criar dashboards interativos com Shiny.
# 14. Atualizar a base de dados automaticamente.

# =========================================================
# EXEMPLO DE AUTOMAÇÃO FUTURA
# =========================================================

# O aluno poderia informar apenas:

# empresas <- c("VALE3", "PETR4", "BBAS3", "WEGE3")

# O script automaticamente:
#   acessa a página de cada empresa
#   extrai os indicadores financeiros
#   limpa os textos
#   transforma os valores em números
#   organiza tudo em uma única tabela
#   exporta a base final

# =========================================================
# EXEMPLOS DE INDICADORES QUE PODEM SER EXTRAÍDOS
# =========================================================

# Nome da empresa
# Setor
# Cotação
# Valor de mercado
# P/L
# P/VP
# Dividend Yield
# ROE
# ROIC
# Margem líquida
# Dívida bruta / patrimônio
# CAGR de receitas
# Liquidez

# =========================================================
# EXEMPLOS DE APLICAÇÕES REAIS
# =========================================================

# 1. Monitoramento de empresas listadas em bolsa.
# 2. Criação de rankings de ações.
# 3. Comparação entre empresas do mesmo setor.
# 4. Triagem inicial de oportunidades de investimento.
# 5. Construção de bases históricas.
# 6. Acompanhamento automático de indicadores.
# 7. Geração de relatórios financeiros.
# 8. Criação de dashboards para tomada de decisão.
# 9. Integração com modelos estatísticos.
# 10. Integração com modelos de machine learning.

# =========================================================
# CUIDADOS IMPORTANTES EM WEB SCRAPING
# =========================================================

# Antes de automatizar a coleta de dados de sites públicos, é importante
# ensinar aos alunos alguns cuidados:

# 1. Verificar se o site permite coleta automatizada.
# 2. Evitar muitas requisições em pouco tempo.
# 3. Usar pausas entre acessos com Sys.sleep().
# 4. Conferir se os seletores HTML continuam funcionando.
# 5. Validar se os dados extraídos fazem sentido.
# 6. Tratar erros quando uma página não estiver disponível.
# 7. Salvar versões dos dados coletados.
# 8. Documentar a fonte das informações.

# =========================================================
# TRANSIÇÃO PARA ANÁLISES AVANÇADAS
# =========================================================

# Depois dessa etapa, os alunos estarão preparados para:

# - automatizar coletas em sites públicos;
# - criar bases de dados atualizadas;
# - integrar web scraping com APIs;
# - desenvolver dashboards financeiros;
# - criar relatórios automáticos;
# - aplicar filtros e rankings;
# - usar machine learning para classificação ou previsão.

# Esse fluxo permite transformar uma consulta manual em um sistema
# automatizado de coleta, organização e análise de dados públicos no R.
