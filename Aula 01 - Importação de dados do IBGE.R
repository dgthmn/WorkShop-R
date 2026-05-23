# =========================================================
# Workshop: Aplicando R no Mundo Real
# Aula 01 - IMPORTAÇÃO DE DADOS DIRETO DO SITE DO IBGE
# =========================================================
# ---------------------------------------------------------
# Pacotes necessários
# ---------------------------------------------------------
# rstudioapi - Definir a trilha de dados automaticamente
# data.table - Exportar e importar dados para o R
# sidrar - Acessar dados do IBGE

###aqui estão os pacotes requeridos para esse script
required_packages <- c("rstudioapi", "sidrar", "data.table")

###pega lista de pacotes requeridos e faz a instalação, tudo autom
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

#Daqui para cima é como se fosse o cabeçalho de trabalho
#doR

# ---------------------------------------------------------
# LEITURA DE ARQUIVOS DOS IBGE
# ---------------------------------------------------------
# Tabela 1612 - produtos agricolas
#O número da tabela escolhida é encontrada no site do IBGE
info<-info_sidra(1612)
info


### PONTO-CHAVE
###Aqui a função (get_sindra) de argumento único (api) do "sidrar"
###significados:
#/t(tabela)/1612 (número de tabela)/n6 (geografia = n + número da tabela de info)
###/all (todas as cidades)/c81 (classificação de categoria)
###/2711 (código dentro da categoria ou all para baixar todos)
###/v (variável)/214 (código da variável)
###/p (período)/2024 (ano que queremos trabalahar)
milho_municipio <- get_sidra(
  api = "/t/1612/n6/all/c81/2711/v/214/p/2024"
)

head(milho_municipio)

###salvando em excel
fwrite(milho_municipio, "milho_municipio.csv")

# =========================================================
# PRÓXIMOS PASSOS: AUTOMAÇÃO DE APIs DO IBGE NO R
# =========================================================

# Depois que os alunos entenderem como acessar uma tabela do IBGE
# manualmente usando o pacote sidrar, o próximo passo é automatizar
# esse processo.

# A ideia é criar um sistema em que o aluno precise informar apenas:
#
# 1. O número da tabela do SIDRA.
# 2. O nome do arquivo que deseja salvar.
# 3. Opcionalmente, o ano, produto, município, estado ou variável.

# A partir disso, o R pode montar automaticamente a API correta,
# importar os dados e salvar o resultado.

# Em análises automáticas com APIs do IBGE, podemos criar scripts para:

# 1. Consultar automaticamente as informações de uma tabela do SIDRA.
# 2. Identificar quais variáveis, períodos e classificações existem.
# 3. Montar a chamada da API sem o aluno precisar copiar o link manualmente.
# 4. Baixar dados por município, estado, região ou Brasil.
# 5. Repetir o download para vários anos.
# 6. Repetir o download para vários produtos agrícolas.
# 7. Organizar os dados em formato tabular.
# 8. Padronizar nomes de colunas.
# 9. Exportar automaticamente arquivos CSV.
# 10. Criar gráficos e mapas a partir dos dados baixados.
# 11. Integrar os dados do IBGE com dados climáticos, agrícolas ou econômicos.
# 12. Criar relatórios automáticos em HTML, Word ou PDF usando Quarto.
# 13. Criar dashboards interativos com Shiny.
# 14. Transformar consultas repetitivas em uma ferramenta simples para tomada de decisão.

# Exemplo de lógica futura:

# O aluno informa:
# tabela <- 1612
# nome_arquivo <- "milho_municipio.csv"

# O script automaticamente:
#   consulta as informações da tabela
#   identifica as opções disponíveis
#   monta a API
#   baixa os dados
#   organiza a tabela
#   salva o arquivo final

# Esse fluxo permite sair de uma consulta manual para um sistema
# automatizado de coleta e análise de dados públicos do IBGE no R.