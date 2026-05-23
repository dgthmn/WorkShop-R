# =========================================================
# Workshop: Aplicando R no Mundo Real
# Aula 07 - CRIAÇÃO DE APLICATIVOS NO R
# =========================================================
# shiny - Criar aplicações web interativas no R
# shinythemes - Aplicar temas visuais prontos em aplicativos Shiny
# shinyWidgets - Adicionar widgets avançados e componentes modernos no Shiny
# DT - Criar tabelas interativas com filtros, paginação e exportação
# plotly - Criar gráficos interativos e dinâmicos
# dplyr - Manipulação e transformação de dados
# stringr - Manipulação de textos e strings
# data.table - Importar e exportar dados de forma rápida e eficiente
# sidrar - Baixar dados oficiais do IBGE via API SIDRA
# bslib - Personalizar temas e aparência visual do Shiny com Bootstrap
# htmltools - Criar e manipular elementos HTML no Shiny
# scales - Formatar e personalizar escalas de gráficos

library(shiny)
library(shinythemes)
library(shinyWidgets)
library(DT)
library(plotly)
library(dplyr)
library(stringr)
library(data.table)
library(sidrar)
library(bslib)
library(htmltools)
library(scales)

# =========================================================
# APP SHINY - IMPORTAÇÃO DE DADOS DO IBGE / SIDRA
# Versão interativa e demonstrativa
# =========================================================
# Objetivo:
# - Buscar dados do SIDRA/IBGE de forma visual
# - Permitir filtros dinâmicos nas colunas retornadas
# - Exibir tabela, resumo e gráficos
# - Permitir download dos resultados filtrados
# =========================================================

ui <- fluidPage(
  theme = bs_theme(
    version = 5,
    bootswatch = "flatly",
    primary = "#0d6efd",
    secondary = "#6610f2",
    success = "#198754",
    base_font = font_google("Poppins")
  ),
  
  tags$head(
    tags$style(HTML("
      .hero-card {
        background: linear-gradient(135deg, #0d6efd 0%, #6610f2 100%);
        color: white;
        border-radius: 22px;
        padding: 28px;
        box-shadow: 0 10px 30px rgba(13,110,253,0.22);
        margin-bottom: 18px;
      }
      .soft-card {
        background: white;
        border-radius: 20px;
        padding: 18px;
        box-shadow: 0 8px 24px rgba(0,0,0,0.08);
        margin-bottom: 18px;
      }
      .kpi-box {
        border-radius: 18px;
        padding: 16px;
        color: white;
        text-align: center;
        box-shadow: 0 8px 22px rgba(0,0,0,0.12);
      }
      .kpi-blue { background: linear-gradient(135deg, #0d6efd, #3d8bfd); }
      .kpi-purple { background: linear-gradient(135deg, #6610f2, #8540f5); }
      .kpi-green { background: linear-gradient(135deg, #198754, #20c997); }
      .kpi-title { font-size: 14px; opacity: .9; }
      .kpi-value { font-size: 28px; font-weight: 700; }
      .section-title {
        font-size: 22px;
        font-weight: 700;
        color: #1f2937;
        margin-bottom: 10px;
      }
      .small-note {
        color: #6c757d;
        font-size: 13px;
      }
      .btn-big {
        font-size: 16px !important;
        padding: 10px 18px !important;
        border-radius: 12px !important;
      }
      .search-download-bar {
        display: flex;
        justify-content: flex-end;
        align-items: center;
        gap: 12px;
        flex-wrap: nowrap;
      }
      .search-wrap {
        display: flex;
        align-items: center;
        gap: 6px;
      }
      .search-wrap label {
        margin: 0;
        font-size: 16px;
        font-weight: 600;
      }
    "))
  ),
  
  fluidRow(
    column(
      12,
      div(
        class = "hero-card",
        h1(
          icon("chart-column"),
          "Dados do IBGE na prática",
          style = "font-weight:800;"
        ),
        p("Busque, filtre, visualize e exporte dados do IBGE em um app moderno e interativo."),
        p(
          class = "small-note",
          "Demonstração desenvolvida para transformar um script simples em uma experiência visual muito mais profissional."
        )
      )
    )
  ),
  
  fluidRow(
    column(
      width = 3,
      div(
        class = "soft-card",
        div(class = "section-title", "Configuração da busca"),
        
        numericInput("tabela", "Tabela SIDRA", value = 1612, min = 1),
        
        textInput(
          "api_path",
          "API personalizada",
          value = "/t/1612/n6/all/c81/2711/v/214/p/2024"
        ),
        
        actionBttn(
          "buscar",
          "Buscar dados",
          style = "gradient",
          color = "primary",
          class = "btn-big"
        ),
        br(), br(),
        
        actionBttn(
          "carregar_exemplo",
          "Carregar exemplo da aula",
          style = "jelly",
          color = "success",
          class = "btn-big"
        ),
        
        hr(),
        h4("Informações da tabela"),
        verbatimTextOutput("info_tabela", placeholder = TRUE),
        
        tags$div(
          class = "small-note",
          "Dica: você pode manter a API padrão da aula ou colar qualquer rota do SIDRA para testar outros dados."
        )
      )
    ),
    
    column(
      width = 9,
      
      fluidRow(
        column(
          4,
          div(
            class = "kpi-box kpi-blue",
            div(class = "kpi-title", "Linhas"),
            div(class = "kpi-value", textOutput("n_linhas", inline = TRUE))
          )
        ),
        column(
          4,
          div(
            class = "kpi-box kpi-purple",
            div(class = "kpi-title", "Colunas"),
            div(class = "kpi-value", textOutput("n_colunas", inline = TRUE))
          )
        ),
        column(
          4,
          div(
            class = "kpi-box kpi-green",
            div(class = "kpi-title", "Municípios"),
            div(class = "kpi-value", textOutput("n_grupos", inline = TRUE))
          )
        )
      ),
      
      br(),
      
      div(
        class = "soft-card",
        div(class = "section-title", "Filtros dinâmicos"),
        uiOutput("filtros_ui")
      ),
      
      div(
        class = "soft-card",
        
        fluidRow(
          column(
            4,
            div(class = "section-title", "Tabela de dados filtrada")
          ),
          column(
            8,
            div(
              class = "search-download-bar",
              div(
                class = "search-wrap",
                tags$label("Search:", `for` = "search_table"),
                textInput(
                  "search_table",
                  NULL,
                  placeholder = "Buscar...",
                  width = "160px"
                )
              ),
              downloadButton(
                "download_csv",
                "Baixar CSV",
                class = "btn btn-primary btn-big"
              ),
              downloadButton(
                "download_xlsx",
                "Baixar Excel",
                class = "btn btn-success btn-big"
              )
            )
          )
        ),
        
        DTOutput("tabela_dados")
      )
    )
  ),
  
  fluidRow(
    column(
      6,
      div(
        class = "soft-card",
        div(class = "section-title", "Resumo dos dados"),
        tableOutput("resumo_colunas")
      )
    ),
    column(
      6,
      div(
        class = "soft-card",
        div(class = "section-title", "Visualização interativa"),
        uiOutput("plot_controls"),
        plotlyOutput("grafico", height = "420px")
      )
    )
  )
)

server <- function(input, output, session) {
  
  dados_raw <- reactiveVal(NULL)
  info_raw  <- reactiveVal(NULL)
  
  observeEvent(input$carregar_exemplo, {
    updateNumericInput(session, "tabela", value = 1612)
    updateTextInput(session, "api_path", value = "/t/1612/n6/all/c81/2711/v/214/p/2024")
    showNotification("Exemplo da aula carregado com sucesso.", type = "message")
  })
  
  observeEvent(input$buscar, {
    req(input$tabela, input$api_path)
    
    tryCatch({
      info <- info_sidra(input$tabela)
      dados <- get_sidra(api = input$api_path)
      
      dados_raw(as.data.frame(dados))
      info_raw(info)
      
      showNotification("Dados carregados com sucesso!", type = "message")
    }, error = function(e) {
      showNotification(
        paste("Erro ao buscar dados:", e$message),
        type = "error",
        duration = 8
      )
    })
  })
  
  output$info_tabela <- renderPrint({
    req(info_raw())
    info_raw()
  })
  
  output$filtros_ui <- renderUI({
    req(dados_raw())
    dados <- dados_raw()
    
    filtros <- lapply(names(dados), function(col) {
      x <- dados[[col]]
      
      if (is.numeric(x)) {
        rng <- range(x, na.rm = TRUE)
        if (all(is.finite(rng))) {
          sliderInput(
            inputId = paste0("filtro_", col),
            label = col,
            min = floor(rng[1]),
            max = ceiling(rng[2]),
            value = c(floor(rng[1]), ceiling(rng[2]))
          )
        }
      } else {
        vals <- sort(unique(as.character(x)))
        pickerInput(
          inputId = paste0("filtro_", col),
          label = col,
          choices = vals,
          selected = vals,
          multiple = TRUE,
          options = list(
            `actions-box` = TRUE,
            `live-search` = TRUE
          )
        )
      }
    })
    
    tagList(filtros)
  })
  
  dados_filtrados <- reactive({
    req(dados_raw())
    dados <- dados_raw()
    
    for (col in names(dados)) {
      id <- paste0("filtro_", col)
      val <- input[[id]]
      
      if (!is.null(val)) {
        if (is.numeric(dados[[col]]) && length(val) == 2) {
          dados <- dados %>%
            filter(.data[[col]] >= val[1], .data[[col]] <= val[2])
        } else {
          dados <- dados %>%
            filter(as.character(.data[[col]]) %in% val)
        }
      }
    }
    
    dados
  })
  
  output$n_linhas <- renderText({
    req(dados_filtrados())
    comma(nrow(dados_filtrados()))
  })
  
  output$n_colunas <- renderText({
    req(dados_filtrados())
    ncol(dados_filtrados())
  })
  
  output$n_grupos <- renderText({
    req(dados_filtrados())
    dados <- dados_filtrados()
    
    possiveis <- names(dados)[str_detect(
      names(dados),
      regex("municipio|município|local|cidade|city|estado|uf|regiao|região|grupo|nome", ignore_case = TRUE)
    )]
    
    if (length(possiveis) > 0) {
      as.character(scales::comma(length(unique(as.character(dados[[possiveis[1]]])))))
    } else {
      "-"
    }
  })
  
  output$tabela_dados <- renderDT({
    req(dados_filtrados())
    
    datatable(
      dados_filtrados(),
      options = list(
        dom = "rtip",
        pageLength = 10,
        scrollX = TRUE,
        autoWidth = TRUE
      ),
      rownames = FALSE,
      filter = "top"
    )
  })
  
  proxy_tabela <- DT::dataTableProxy("tabela_dados")
  
  observeEvent(input$search_table, {
    DT::updateSearch(
      proxy_tabela,
      keywords = list(global = input$search_table, columns = NULL)
    )
  }, ignoreInit = FALSE)
  
  output$resumo_colunas <- renderTable({
    req(dados_filtrados())
    dados <- dados_filtrados()
    
    data.frame(
      Coluna  = names(dados),
      Classe  = sapply(dados, function(x) class(x)[1]),
      Missing = sapply(dados, function(x) sum(is.na(x))),
      Unicos  = sapply(dados, function(x) length(unique(x)))
    )
  }, striped = TRUE, bordered = TRUE, hover = TRUE)
  
  output$plot_controls <- renderUI({
    req(dados_filtrados())
    dados <- dados_filtrados()
    
    num_cols <- names(dados)[sapply(dados, is.numeric)]
    cat_cols <- names(dados)[!sapply(dados, is.numeric)]
    
    x_default <- if (length(cat_cols) >= 1) {
      cat_cols[1]
    } else if (length(names(dados)) >= 1) {
      names(dados)[1]
    } else {
      NULL
    }
    
    y_default <- if (length(num_cols) >= 1) num_cols[1] else NULL
    
    tagList(
      fluidRow(
        column(
          6,
          selectInput(
            "x_plot",
            "Coluna categórica / eixo X",
            choices = c(cat_cols, num_cols),
            selected = x_default
          )
        ),
        column(
          6,
          selectInput(
            "y_plot",
            "Coluna numérica / eixo Y",
            choices = num_cols,
            selected = y_default
          )
        )
      )
    )
  })
  
  output$grafico <- renderPlotly({
    req(dados_filtrados())
    dados <- dados_filtrados()
    
    validate(
      need(!is.null(input$x_plot), "Selecione uma coluna para o eixo X."),
      need(!is.null(input$y_plot), "Selecione uma coluna numérica para o eixo Y."),
      need(input$x_plot %in% names(dados), "A coluna escolhida para o eixo X não está disponível."),
      need(input$y_plot %in% names(dados), "A coluna escolhida para o eixo Y não está disponível."),
      need(is.numeric(dados[[input$y_plot]]), "O eixo Y precisa ser uma coluna numérica.")
    )
    
    dados_plot <- dados %>%
      mutate(
        x_var = as.character(.data[[input$x_plot]]),
        y_var = suppressWarnings(as.numeric(.data[[input$y_plot]]))
      ) %>%
      filter(!is.na(x_var), !is.na(y_var)) %>%
      group_by(x_var) %>%
      summarise(
        valor = mean(y_var, na.rm = TRUE),
        .groups = "drop"
      ) %>%
      filter(is.finite(valor)) %>%
      arrange(desc(valor)) %>%
      slice_head(n = 20)
    
    validate(
      need(nrow(dados_plot) > 0, "Não há dados disponíveis para gerar o gráfico com os filtros selecionados.")
    )
    
    plot_ly(
      data = dados_plot,
      x = ~valor,
      y = ~reorder(x_var, valor),
      type = "bar",
      orientation = "h",
      marker = list(color = "#6610f2"),
      hovertemplate = paste0(
        "<b>", input$x_plot, ":</b> %{y}<br>",
        "<b>Média de ", input$y_plot, ":</b> %{x:.2f}<extra></extra>"
      )
    ) %>%
      layout(
        xaxis = list(title = paste("Média de", input$y_plot)),
        yaxis = list(title = input$x_plot, automargin = TRUE),
        margin = list(l = 180, r = 20, t = 20, b = 50),
        showlegend = FALSE
      )
  })
  
  output$download_csv <- downloadHandler(
    filename = function() {
      paste0("dados_ibge_filtrados_", Sys.Date(), ".csv")
    },
    content = function(file) {
      fwrite(dados_filtrados(), file)
    }
  )
  
  output$download_xlsx <- downloadHandler(
    filename = function() {
      paste0("dados_ibge_filtrados_", Sys.Date(), ".xlsx")
    },
    content = function(file) {
      if (!require(openxlsx)) install.packages("openxlsx")
      openxlsx::write.xlsx(dados_filtrados(), file)
    }
  )
}

shinyApp(ui, server)