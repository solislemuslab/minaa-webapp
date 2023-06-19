AlignTab <- tabPanel(
  "Align",
  sidebarLayout(
    sidebarPanel(
      fluidRow(
        # Input network G
        fileInput(
          "align_GFile",
          "Upload network G",
          accept = c(
            "text/csv",
            "text/comma-separated-values",
            "text/tab-separated-values",
            "text/plain",
            ".csv",
            ".tsv"
          ),
          placeholder = "No file selected (required)",
          width = "100%"
        ),
        p(style = "margin: -16px"),
        # Input network H
        fileInput(
          "align_HFile",
          "Upload network H",
          accept = c(
            "text/csv",
            "text/comma-separated-values",
            "text/tab-separated-values",
            "text/plain",
            ".csv",
            ".tsv"
          ),
          placeholder = "No file selected (required)",
          width = "100%"
        ),
        p(style = "margin: -16px"),
        # Input biological data
        fileInput(
          "align_BFile",
          "Upload biological data",
          accept = c(
            "text/csv",
            "text/comma-separated-values",
            "text/tab-separated-values",
            "text/plain",
            ".csv",
            ".tsv"
          ),
          placeholder = "No file selected (optional)",
          width = "100%"
        ),
        p(style = "margin: -16px"),
        # Specify input format
        checkboxInput("do_vis", "Generate Visual", TRUE)
      ),
      fluidRow(
        # Specify balancing parameters
        column(
          4,
          numericInput(
            "alphaIn",
            label = "\U03B1",
            value = 1,
            min = 0,
            max = 1,
            step = 0.01,
            width = "84px"
          )
        ),
        column(
          4,
          numericInput(
            "betaIn",
            label = "\U03B2",
            value = 1,
            min = 0,
            max = 1,
            step = 0.01,
            width = "84px"
          )
        ),
        # Submit Button
        column(
          4,
          actionButton("executeAlign", label = "Run", width = "84px")
        )
      )
    ),
    mainPanel(
      # Set the style of the verbatimTextOutput box
      tags$head(
        tags$style(
          HTML("
                  .my-verbatim {
                    max-height: 200px;
                    overflow-y: auto;
                  }
                ")
        )
      ),
      # tableOutput('contents1')
      verbatimTextOutput("align_contentsG"),
      verbatimTextOutput("align_contentsH"),
      verbatimTextOutput("align_contentsB"),
      #   fluidRow(
      #     column(width=12,
      #            fluidRow(style = "max-height:100px; margin:10px",
      #                     verbatimTextOutput('contents1'),
      #                     ),
      #            fluidRow(style = "max-height:100px; margin:10px",
      #                     verbatimTextOutput('contents2'),
      #                    ),
      #           fluidRow(style = "max-height:100px; margin:10px",
      #                    verbatimTextOutput('contents3'),
      #           )
      # )
      # )
    )
  )
)
