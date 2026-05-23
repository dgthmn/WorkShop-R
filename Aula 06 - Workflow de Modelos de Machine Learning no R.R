# =========================================================
# Workshop: Aplicando R no Mundo Real
# Aula 06 - WORKFLOW DE MODELOS MACHINE LEARNING NO R
# =========================================================
# ---------------------------------------------------------
# Pacotes necessários
# ---------------------------------------------------------
# rstudioapi - Definir a trilha de dados automaticamente
# data.table - Exportar e importar dados para o R
# dplyr - Manipulação de dados
# ggplot2 - Criar gráficos
# tidymodels - Criar workflows modernos de machine learning
# brulee - Ajustar redes neurais usando infraestrutura do torch
# vip - Avaliar importância das variáveis em modelos preditivos

###pacote caret tem muitos modelos para trabalharmos
###nnet redes neurais!


required_packages <- c(
  "rstudioapi",
  "data.table",
  "dplyr",
  "ggplot2",
  "caret",
  "nnet",
  "vip"
)

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
# 1) IMPORTAR A BASE DE DADOS
# =========================================================

###mtcars são dados base do R
# Nesta aula, vamos usar a base mtcars como exemplo didático.
# O objetivo será predizer o consumo de combustível dos carros.
# A variável resposta será mpg.
# As demais variáveis serão usadas como preditoras.

dados <- mtcars

# Transformar nomes dos carros em coluna
dados$Carro <- rownames(mtcars)
rownames(dados) <- NULL

# Visualizar as primeiras linhas
head(dados)

# Ver estrutura da base
str(dados)

# =========================================================
# 2) DEFINIR O PROBLEMA DE MACHINE LEARNING
# =========================================================

# Problema:
# Predizer mpg, ou seja, milhas por galão.

# Tipo de problema:
# Regressão, porque a variável resposta é numérica contínua.

# Variável resposta:
# mpg

# Variáveis preditoras:
# cyl, disp, hp, drat, wt, qsec, vs, am, gear, carb

# Remover a coluna Carro, pois ela é apenas identificação
dados_ml <- dados %>%
  select(-Carro)

head(dados_ml)

# =========================================================
# 3) DIVIDIR OS DADOS EM TREINO E TESTE
# =========================================================

set.seed(123)

indice_treino <- caret::createDataPartition(
  dados_ml$mpg,
  p = 0.80,
  list = FALSE
)

treino <- dados_ml[indice_treino, ]
teste  <- dados_ml[-indice_treino, ]

# =========================================================
# 4) CONTROLE DA VALIDAÇÃO CRUZADA
# =========================================================


###cv é o método de validação cruzada
controle <- trainControl(
  method = "cv",
  number = 5,
  savePredictions = "final"
)

# =========================================================
# 5) DEFINIR GRADE DE HIPERPARÂMETROS
###SINTONIZAÇÃO DE HIPERPARÂMETROS!!!
# =========================================================
# size = Número de neurônios na camada oculta
# Define quantos neurônios existirão na camada intermediária da rede neural.
# decay = Regularização
# O parâmetro decay controla o quanto a rede é penalizada por pesos muito grandes.

grade_nn <- expand.grid(
  size = c(3, 5, 7, 10),
  decay = c(0.001, 0.01, 0.1)
)

# =========================================================
# 6) TREINAR REDE NEURAL COM CARET
# =========================================================

set.seed(123)

modelo_nn <- caret::train(
  mpg ~ .,
  data = treino,
  method = "nnet",
  trControl = controle,
  tuneGrid = grade_nn,
  preProcess = c("center", "scale"),
  linout = TRUE,
  trace = FALSE,
  maxit = 500
)

modelo_nn

# =========================================================
# 7) AVALIAR MELHORES HIPERPARÂMETROS
# =========================================================

modelo_nn$bestTune
modelo_nn$results

# =========================================================
# 8) PREDIZER BASE DE TESTE
# =========================================================

#######NO FINAL EU TENHO OS VALORES REAIS E OS VALORES PREDITOS
predicoes <- teste %>%
  mutate(
    .pred = predict(modelo_nn, newdata = teste)
  )

head(predicoes)

# =========================================================
# 9) MÉTRICAS FINAIS
# =========================================================

rmse <- sqrt(mean((predicoes$mpg - predicoes$.pred)^2))
mae  <- mean(abs(predicoes$mpg - predicoes$.pred))
r2   <- cor(predicoes$mpg, predicoes$.pred)^2

resultado_final <- data.frame(
  Modelo = "Rede neural - caret/nnet",
  RMSE = rmse,
  MAE = mae,
  R2 = r2
)

resultado_final
####AQUI O RESULTADO REAL TEVE 
###UM R2 MELHOR DO QUE OS PREDITOS
###PROVÁVEL QUE DEVIDO AO NÚMERO REDUZIDO DE AMOSTRAS
###PQ O NORMAL É OS MODELOS PREDITOS SEREM MELHOR QUE O REAL

# =========================================================
# 10) GRÁFICO: OBSERVADO VS PREDITO
# =========================================================

grafico_predito <- ggplot(predicoes,
                          aes(x = mpg, y = .pred)) +
  geom_point(size = 3) +
  geom_abline(
    intercept = 0,
    slope = 1,
    linetype = "dashed"
  ) +
  labs(
    title = "Valores observados vs valores preditos",
    subtitle = "Modelo de rede neural usando caret",
    x = "Valor observado",
    y = "Valor predito"
  ) +
  theme_minimal()

grafico_predito

# Salvar gráfico
ggsave(
  filename = "observado_vs_predito_rede_neural.png",
  plot = grafico_predito,
  width = 8,
  height = 6,
  dpi = 300
)

# =========================================================
# 11) GRÁFICO DOS RESÍDUOS
# =========================================================

predicoes <- predicoes %>%
  mutate(
    residuo = mpg - .pred
  )

grafico_residuos <- ggplot(predicoes,
                           aes(x = .pred, y = residuo)) +
  geom_point(size = 3) +
  geom_hline(
    yintercept = 0,
    linetype = "dashed"
  ) +
  labs(
    title = "Gráfico de resíduos",
    subtitle = "Diferença entre valor observado e valor predito",
    x = "Valor predito",
    y = "Resíduo"
  ) +
  theme_minimal()

grafico_residuos

ggsave(
  filename = "residuos_rede_neural.png",
  plot = grafico_residuos,
  width = 8,
  height = 6,
  dpi = 300
)

# =========================================================
# 12) EXPORTAR RESULTADOS
# =========================================================

# Salvar predições
fwrite(
  predicoes,
  "predicoes_rede_neural.csv"
)

# Salvar métricas finais
fwrite(
  resultado_final,
  "metricas_rede_neural.csv"
)

# =========================================================
# 13) INTERPRETAÇÃO DOS RESULTADOS
# =========================================================

# Depois de rodar o modelo, os alunos devem interpretar:
#
# 1. Qual foi o RMSE do modelo?
# 2. Qual foi o R² do modelo?
# 3. O modelo está predizendo bem?
# 4. Os pontos do gráfico observado vs predito estão próximos da linha?
# 5. Os resíduos estão distribuídos de forma aleatória?
# 6. O modelo está sofrendo overfitting?
# 7. Quais hiperparâmetros foram escolhidos como melhores?
# 8. A rede neural foi melhor do que um modelo simples?

# =========================================================
# 14) PRÓXIMOS PASSOS: WORKFLOWS AUTOMÁTICOS DE MACHINE LEARNING
# =========================================================

# Depois que os alunos entenderem esse fluxo, o próximo passo é automatizar
# a comparação entre diferentes modelos de machine learning.

# Em workflows automáticos, podemos criar scripts para:

# 1. Testar vários modelos ao mesmo tempo.
# 2. Comparar rede neural, random forest, XGBoost, SVM e regressão regularizada.
# 3. Usar validação cruzada repetida.
# 4. Fazer sintonia automática de hiperparâmetros.
# 5. Selecionar o melhor modelo com base no RMSE, R² ou MAE.
# 6. Salvar automaticamente predições, métricas e gráficos.
# 7. Criar relatórios automáticos em HTML, Word ou PDF usando Quarto.
# 8. Criar dashboards com Shiny para explorar resultados.
# 9. Integrar machine learning com dados climáticos.
# 10. Integrar machine learning com imagens de satélite.
# 11. Integrar machine learning com dados do IBGE.
# 12. Criar sistemas de predição agrícola em tempo real.

# Exemplo de lógica futura:

# Para cada modelo:
#   criar receita
#   definir hiperparâmetros
#   rodar validação cruzada
#   escolher melhor combinação
#   treinar modelo final
#   predizer base de teste
#   salvar métricas
#   salvar gráficos

# Esse fluxo permite transformar uma análise simples em uma plataforma
# completa de modelagem preditiva no R.