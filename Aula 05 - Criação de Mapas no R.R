# =========================================================
# Workshop: Aplicando R no Mundo Real
# Aula 05 - CRIAÇÃO DE MAPAS NO R
# =========================================================
# ---------------------------------------------------------
# Pacotes necessários
# ---------------------------------------------------------
# rstudioapi - Definir a trilha de dados automaticamente
# data.table - Exportar e importar dados para o R
# dplyr - Manipulação de dados
# geobr - Baixar mapas oficiais do Brasil
# sf - Trabalhar com dados espaciais vetoriais
# ggplot2 - Criar mapas e gráficos

required_packages <- c("rstudioapi", "data.table", "dplyr", "geobr", "sf", "ggplot2")

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

# =========================================================
# 1) IMPORTAR OS DADOS DE PRODUÇÃO DE MILHO
# =========================================================

# Este arquivo foi criado na Aula 01 usando dados do IBGE/SIDRA
milho_municipio <- fread("milho_municipio.csv")

# Visualizar as primeiras linhas
head(milho_municipio)

# Ver nomes das colunas
names(milho_municipio)

# =========================================================
# 2) ORGANIZAR A BASE DO IBGE
# =========================================================

# O objetivo é identificar:
# - código do município
# - nome do município
# - valor da produção ou quantidade produzida

# IMPORTANTE:
# Dependendo da tabela baixada no SIDRA, os nomes das colunas podem mudar.
# Por isso, primeiro conferimos names(milho_municipio).

# Exemplo comum:
# coluna "Município (Código)" = código do município
# coluna "Município" = nome do município
# coluna "Valor" = produção

milho_municipio <- milho_municipio %>%
  rename(
    code_muni = `Município (Código)`,
    municipio = Município,
    producao_milho = Valor
  )

# Transformar produção em número
milho_municipio$producao_milho <- as.numeric(milho_municipio$producao_milho)

head(milho_municipio)

# =========================================================
# 3) BAIXAR O MAPA DOS MUNICÍPIOS DO BRASIL
# =========================================================

# Baixar todos os municípios do Brasil
mapa_municipios <- read_municipality(
  code_muni = "all",
  year = 2020
)

# Visualizar o mapa
plot(mapa_municipios["code_muni"])

# =========================================================
# 4) UNIR OS DADOS DO IBGE COM O MAPA
# =========================================================

# A união será feita pela coluna code_muni
# Essa coluna representa o código oficial do município no IBGE.

mapa_milho <- mapa_municipios %>%
  left_join(milho_municipio, by = "code_muni")

# Verificar resultado
head(mapa_milho)

# =========================================================
# 5) CRIAR MAPA DE PRODUÇÃO DE MILHO POR MUNICÍPIO
# =========================================================

ggplot(mapa_milho) +
  geom_sf(aes(fill = producao_milho),
          color = NA) +
  scale_fill_viridis_c(
    option = "C",
    na.value = "gray90",
    name = "Produção de milho"
  ) +
  labs(
    title = "Produção de milho por município",
    subtitle = "Dados importados do IBGE/SIDRA",
    caption = "Fonte: IBGE/SIDRA"
  ) +
  theme_minimal()

# =========================================================
# 6) MELHORAR O MAPA
# =========================================================

mapa_final <- ggplot(mapa_milho) +
  geom_sf(aes(fill = producao_milho),
          color = "white",
          linewidth = 0.05) +
  scale_fill_viridis_c(
    option = "C",
    na.value = "gray90",
    name = "Produção"
  ) +
  labs(
    title = "Mapa agrícola da produção de milho no Brasil",
    subtitle = "Produção por município",
    caption = "Fonte: IBGE/SIDRA"
  ) +
  theme_minimal() +
  theme(
    plot.title = element_text(size = 16, face = "bold"),
    plot.subtitle = element_text(size = 12),
    legend.position = "right"
  )

mapa_final

# =========================================================
# 7) SALVAR O MAPA
# =========================================================

ggsave(
  filename = "mapa_producao_milho_municipio.png",
  plot = mapa_final,
  width = 12,
  height = 8,
  dpi = 300
)

# =========================================================
# 8) FILTRAR APENAS UM ESTADO
# =========================================================

# Exemplo: Mato Grosso
mapa_milho_mt <- mapa_milho %>%
  filter(abbrev_state == "MT")

mapa_mt <- ggplot(mapa_milho_mt) +
  geom_sf(aes(fill = producao_milho),
          color = "white",
          linewidth = 0.2) +
  scale_fill_viridis_c(
    option = "C",
    na.value = "gray90",
    name = "Produção"
  ) +
  labs(
    title = "Produção de milho por município - Mato Grosso",
    subtitle = "Dados importados do IBGE/SIDRA",
    caption = "Fonte: IBGE/SIDRA"
  ) +
  theme_minimal()

mapa_mt

ggsave(
  filename = "mapa_producao_milho_MT.png",
  plot = mapa_mt,
  width = 10,
  height = 8,
  dpi = 300
)

# =========================================================
# 9) CRIAR CLASSES DE PRODUÇÃO
# =========================================================

mapa_milho <- mapa_milho %>%
  mutate(
    classe_producao = case_when(
      is.na(producao_milho) ~ "Sem dados",
      producao_milho == 0 ~ "Sem produção",
      producao_milho > 0 & producao_milho <= 1000 ~ "Baixa",
      producao_milho > 1000 & producao_milho <= 10000 ~ "Média",
      producao_milho > 10000 & producao_milho <= 100000 ~ "Alta",
      producao_milho > 100000 ~ "Muito alta"
    )
  )

# Verificar classes
table(mapa_milho$classe_producao)

# =========================================================
# 10) MAPA COM CLASSES DE PRODUÇÃO
# =========================================================

mapa_classes <- ggplot(mapa_milho) +
  geom_sf(aes(fill = classe_producao),
          color = NA) +
  labs(
    title = "Classes de produção de milho por município",
    subtitle = "Classificação baseada na produção municipal",
    fill = "Classe",
    caption = "Fonte: IBGE/SIDRA"
  ) +
  theme_minimal()

mapa_classes

# =========================================================
# 11) EXPORTAR BASE FINAL
# =========================================================

# Salvar tabela com dados e informações do mapa
fwrite(
  st_drop_geometry(mapa_milho),
  "base_mapa_milho_municipio.csv"
)

# Salvar shapefile com os dados unidos
st_write(
  mapa_milho,
  "mapa_milho_municipio.shp",
  delete_layer = TRUE
)

# =========================================================
# 12) PRÓXIMOS PASSOS: MAPAS AUTOMÁTICOS NO R
# =========================================================

# Depois que os alunos entenderem como criar um mapa agrícola simples,
# o próximo passo é automatizar a criação de mapas para diferentes culturas,
# anos, estados e indicadores.

# Em análises automáticas de mapas agrícolas, podemos criar scripts para:

# 1. Baixar dados automaticamente do IBGE/SIDRA.
# 2. Baixar mapas oficiais de municípios, estados e regiões.
# 3. Unir dados agrícolas com mapas usando o código do município.
# 4. Criar mapas para diferentes culturas, como milho, soja, arroz e feijão.
# 5. Criar mapas para diferentes anos.
# 6. Comparar produção agrícola entre municípios.
# 7. Identificar regiões com maior concentração de produção.
# 8. Criar mapas por estado automaticamente.
# 9. Criar mapas com classes de produção.
# 10. Exportar mapas em PNG, PDF ou TIFF.
# 11. Criar relatórios automáticos com Quarto.
# 12. Criar dashboards interativos com Shiny.
# 13. Integrar mapas agrícolas com clima.
# 14. Integrar mapas agrícolas com imagens de satélite.
# 15. Criar sistemas de monitoramento agrícola territorial.

# Exemplo de lógica futura:

# Para cada cultura:
#   baixar dados do IBGE
#   baixar mapa dos municípios
#   unir tabela com mapa
#   criar mapa nacional
#   criar mapas por estado
#   exportar figuras
#   gerar relatório final

# Esse fluxo permite transformar uma tabela agrícola simples em um
# sistema automatizado de análise espacial e tomada de decisão no R.