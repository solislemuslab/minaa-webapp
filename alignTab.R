# Load required libraries
library(shiny)
library(shinyWidgets)
library(colourpicker)
library(shinyBS) # For popovers
library(plotly)
library(shinythemes)
library(shinycssloaders)

AlignTab <- tabPanel(
  "Run",
  sidebarLayout(
    sidebarPanel(
      style = "
        border-radius: 10px;
      ",
      div(
        style = "
          padding: 15px;
        ",
        fluidRow(
          h4(
            "Upload Networks and Data",
            style = "color: #0056b3;"
          ),
          # File uploads
          div(
            style = "
              margin-bottom: 20px;
            ",
            # Input network G
            fileInput(
              "align_GFile",
              "Upload Network G (Required)",
              accept = c(".csv", ".tsv"),
              placeholder = "No file selected"
            ),
            # Input network H
            fileInput(
              "align_HFile",
              "Upload Network H (Required)",
              accept = c(".csv", ".tsv"),
              placeholder = "No file selected"
            ),
            # Input biological data
            fileInput(
              "align_BFile",
              "Upload Biological Data (Optional)",
              accept = c(".csv", ".tsv"),
              placeholder = "No file selected"
            )
          ),
          # Biological matrix type
          radioButtons(
            inputId = "matrix_type",
            label = "Select Biological Matrix Type:",
            choices = list("Cost Matrix" = "cost", "Similarity Matrix" = "similarity"),
            selected = "cost"
          ),
          # Generate visual checkbox
          checkboxInput("do_vis", "Generate Visual", TRUE),
          tags$hr()
        ),
        # Alignment parameters with collapsible sections
        fluidRow(
          h4("Alignment Parameters"),
          tags$details(
            tags$summary("Show/Hide Alignment Parameters"),
            column(
              6,
              numericInput(
                "alphaIn",
                label = HTML("\U03B1 (Alpha) [Range: 0 - 1] <a id='info_alphaIn' href='#' style='text-decoration:none;'><i class='fa fa-question-circle'></i></a>"),
                value = 1,
                min = 0,
                max = 1,
                step = 0.01
              ),
              bsTooltip("info_alphaIn", "The GDV-edge weight balancer", "right")
            ),
            column(
              6,
              numericInput(
                "betaIn",
                label = HTML("\U03B2 (Beta) [Range: 0 - 1] <a id='info_betaIn' href='#' style='text-decoration:none;'><i class='fa fa-question-circle'></i></a>"),
                value = 1,
                min = 0,
                max = 1,
                step = 0.01
              ),
              bsTooltip("info_betaIn", "The topological-biological cost matrix balancer", "right")
            ),
            tags$hr()
          )
        ),
        # Size and Degree Parameters with collapsible sections
        fluidRow(
          h4("Size and Degree Parameters"),
          tags$details(
            tags$summary("Show/Hide Size and Degree Parameters"),
            column(
              6,
              numericInput(
                "size_aligned",
                label = HTML("Size Aligned <a id='info_size_aligned' href='#' style='text-decoration:none;'><i class='fa fa-question-circle'></i></a>"),
                value = 1,
                step = 1,
                min = 0
              ),
              bsTooltip("info_size_aligned", "Sizes of aligned nodes.", placement = "right")
            ),
            column(
              6,
              numericInput(
                "zero_degree",
                label = HTML("Degree Align <a id='info_zero_degree' href='#' style='text-decoration:none;'><i class='fa fa-question-circle'></i></a>"),
                value = 0,
                step = 1,
                min = 0
              ),
              bsTooltip("info_zero_degree", "Minimum degree to show nodes in the graph.", placement = "right")
            ),
            column(
              6,
              numericInput(
                "th_align",
                label = HTML("Threshold Align (Range: (0, 1]) <a id='info_th_align' href='#' style='text-decoration:none;'><i class='fa fa-question-circle'></i></a>"),
                value = 0.5,
                step = 0.01,
                min = .Machine$double.eps,
                max = 1
              ),
              bsTooltip("info_th_align", "Minimum threshold values required for alignment.", placement = "right")
            ),
            tags$hr()
          )
        ),
        # Color Options with collapsible sections
        fluidRow(
          h4("Color Options"),
          tags$details(
            tags$summary("Show/Hide Color Options"),
            column(
              6,
              colourInput("node_G_color", "Color for Nodes in G", value = "#3F8C61")
            ),
            column(
              6,
              colourInput("node_H_color", "Color for Nodes in H", value = "#11A0D9")
            ),
            column(
              6,
              colourInput("edge_G_color", "Color for Edges in G", value = "grey")
            ),
            column(
              6,
              colourInput("edge_H_color", "Color for Edges in H", value = "grey")
            ),
            column(
              6,
              colourInput("aligned_G_color", "Color for Aligned Nodes in G", value = "#F2B705")
            ),
            column(
              6,
              colourInput("aligned_H_color", "Color for Aligned Nodes in H", value = "#F2B705")
            ),
            column(
              12,
              colourInput("line_GH_color", "Color for alignments between G and H", value = "#9491D9")
            ),
            tags$hr()
          )
        ),
        # Run button
        fluidRow(
          style = "text-align: center;",
          actionButton(
            "submitInputs",
            label = "Run",
            style = "
              background-color: #007bff;
              border-color: #0056b3;
              color: #e9f7fc;
              font-weight: bold;
              btn-lg;
              min-width: 180px;
              margin-top: 30px;
            "
          )
        )
      )
    ),
    mainPanel(
      div(
        style = "
          background-color: #e9f7fc;
          padding: 15px;
          border-radius: 10px;
          margin-bottom: 20px;
        ",
        uiOutput("alignmentSummaryUI")
      ),
      # Plotly plot output with specified dimensions
      withSpinner(# Add spinner for loading
        caption = getOption("spinner.caption", "Awaiting Submission..."),
        plotlyOutput("networkPlot", height = "1000px", width = "1000px")
      ),
      # Conditional panel to show download button only when plot is generated
      conditionalPanel(
        condition = "output.plotGenerated", # Shows only when the plot is generated
        fluidRow(
          column(
            6,
            selectInput("downloadFormat", "Select Format",
              choices = c("PNG", "JPEG"), selected = "PNG"
            )
          ),
          column(
            6,
            downloadButton("downloadPlot", "Download Plot", style = "btn-success")
          )
        )
      ),
      # Conditional UI output for displaying the name mapping table if truncation occurs
      uiOutput("nameMappingUI")
    )
  )
)
