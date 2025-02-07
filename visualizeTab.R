VisualizeTab <- tabPanel(
  "Visualize",
  sidebarLayout(
    sidebarPanel(
      style = "
        border-radius: 10px;
      ",
      div(
        style = "
          padding: 15px;
        ",
        tags$head(
          tags$style(HTML("
            h4 {
              color: #0056b3;
              margin-top: 10px;
              margin-bottom: 15px;
            }
          "))
        ),
        # Instruction for running MiNAA first
        div(
          style = "font-size: 16px; font-weight: bold; color: #D9534F; margin-bottom: 15px;",
          "Please run MiNAA first to generate the required file (Alignment Matrix) before uploading."
        ),
        # File input section
        fluidRow(
          div(
            style = "
              margin-bottom: 20px;
            ",
            fileInput(
              "vis_GFile",
              "Upload network G",
              accept = c(".csv"),
              placeholder = "No file selected (required)",
              width = "100%"
            ),
            fileInput(
              "vis_HFile",
              "Upload network H",
              accept = c(".csv"),
              placeholder = "No file selected (required)",
              width = "100%"
            ),
            fileInput(
              "vis_AFile",
              "Upload Alignment Matrix",
              accept = c(".csv"),
              placeholder = "No file selected (required)",
              width = "100%"
            )
          )
        ),
        # Size and Degree Parameters
        fluidRow(
          h4("Size and Degree Parameters"),
          tags$details(
            tags$summary("Show/Hide Size and Degree Parameters"),
            column(
              6,
              numericInput(
                "vis_size_aligned",
                label = HTML("Size Aligned <a id='info_size_aligned_' href='#' style='text-decoration:none;'><i class='fa fa-question-circle'></i></a>"),
                value = 1,
                step = 1,
                min = 0
              ),
              bsTooltip("info_size_aligned_", "Sizes of aligned nodes.", placement = "right")
            ),
            column(
              6,
              numericInput(
                "vis_zero_degree",
                label = HTML("Degree Align <a id='info_zero_degree_' href='#' style='text-decoration:none;'><i class='fa fa-question-circle'></i></a>"),
                value = 0,
                step = 1,
                min = 0
              ),
              bsTooltip("info_zero_degree_", "Minimum degree to show nodes in the graph.", placement = "right")
            ),
            column(
              6,
              numericInput(
                "vis_th_align",
                label = HTML("Threshold Align (Range: (0, 1] <a id='info_th_align_' href='#' style='text-decoration:none;'><i class='fa fa-question-circle'></i></a>"),
                value = 0.5,
                step = 0.01,
                min = .Machine$double.eps,
                max = 1
              ),
              bsTooltip("info_th_align_", "Minimum threshold values required for alignment.", placement = "right")
            )
          )
        ),
        # Color Options
        fluidRow(
          h4("Color Options"),
          tags$details(
            tags$summary("Show/Hide Color Options"),
            column(
              6,
              colourInput("vis_node_G_color", "Color for Nodes in G", value = "#3F8C61") # Unique ID
            ),
            column(
              6,
              colourInput("vis_node_H_color", "Color for Nodes in H", value = "#11A0D9") # Unique ID
            ),
            column(
              6,
              colourInput("vis_edge_G_color", "Color for Edges in G", value = "grey") # Unique ID
            ),
            column(
              6,
              colourInput("vis_edge_H_color", "Color for Edges in H", value = "grey") # Unique ID
            ),
            column(
              6,
              colourInput("vis_aligned_G_color", "Color for Aligned Nodes in G", value = "#F2B705") # Unique ID
            ),
            column(
              6,
              colourInput("vis_aligned_H_color", "Color for Aligned Nodes in H", value = "#F2B705") # Unique ID
            ),
            column(
              12,
              colourInput("vis_line_GH_color", "Color for alignments between G and H", value = "#9491D9") # Unique ID
            )
          )
        ),
        # Run button
        fluidRow(
          style = "text-align: center;",
          actionButton(
            "vis_submitInputs",
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
        class = "summary-section",
        uiOutput("alignmentSummaryUI_")
      ),
      # Plotly output
      withSpinner(
        caption = getOption("spinner.caption", "Awaiting Submission..."),
        plotlyOutput("vis_networkPlot", height = "1000px", width = "1000px")
      ),
      # Conditional panel for downloading the plot
      conditionalPanel(
        condition = "output.vis_plotGenerated == true",
        fluidRow(
          column(
            6,
            selectInput("vis_downloadFormat", "Select Format",
              choices = c("PNG", "JPEG"), selected = "PNG"
            ) # Unique ID
          ),
          column(
            6,
            downloadButton("vis_downloadPlot", "Download Plot") # Unique ID
          )
        )
      ),
      # Name Mapping Table Output
      uiOutput("nameMappingUI_")
    )
  )
)
