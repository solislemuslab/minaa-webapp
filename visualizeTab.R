VisualizeTab <- tabPanel(
  "Visualize",
  sidebarLayout(
    sidebarPanel(
      fluidRow(
        # Input network G
        fileInput(
          "vis_GFile",
          "Upload network G",
          accept = c(".csv"),
          placeholder = "No file selected (required)",
          width = "100%"
        ),
        p(style = "margin: -16px"),
        # Input network H
        fileInput(
          "vis_HFile",
          "Upload network H",
          accept = c(".csv"),
          placeholder = "No file selected (required)",
          width = "100%"
        ),
        p(style = "margin: -16px"),
        # Input Alignment matrix
        fileInput(
          "vis_AFile",
          "Upload Alignment Matrix",
          accept = c(".csv"),
          placeholder = "No file selected (required)",
          width = "100%"
        ),
        p(style = "margin: -16px")
      ),
      fluidRow(
        # Submit Button
        actionButton("executeVisualize", label = "Run", width = "84px")
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
      verbatimTextOutput("vis_contentsG"),
      verbatimTextOutput("vis_contentsH"),
      verbatimTextOutput("vis_contentsA")
    )
  )
)
