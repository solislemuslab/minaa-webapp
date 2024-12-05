ResultsTab <- tabPanel(
  "Results",
  sidebarLayout(
    sidebarPanel(
      tags$head(
        tags$style(HTML("
          .sidebar-panel {
            background-color: #f9f9f9;
            border: 1px solid #ddd;
            padding: 15px;
            border-radius: 10px;
          }
          .btn-primary {
            background-color: #007bff !important;
            border-color: #0056b3 !important;
            font-weight: bold;
          }
          h4 {
            color: #0056b3;
            margin-top: 20px;
            margin-bottom: 15px;
            padding-left: 10px;
          }
          .summary-section {
            background-color: #e9f7fc;
            padding: 15px;
            border-radius: 10px;
            margin-bottom: 20px;
          }
          .upload-section {
            background-color: #fcf2e9;
            padding: 15px;
            border-radius: 10px;
            margin-bottom: 20px;
          }
          .aligned-input {
            margin-left: 10px;
            margin-right: 10px;
            padding: 10px;
          }
          .aligned-input label {
            margin-bottom: 5px;
            display: block;
          }
        "))
      ),
      div(class = "sidebar-panel",
          fluidRow(
            h4("Select and Manage Files"),
            
            # File Selection UI
            div(class = "upload-section",
                uiOutput("select.folder"),
                pickerInput(
                  inputId = "file.name",
                  label = "Select Files",
                  choices = NULL,  # To be dynamically populated
                  multiple = TRUE,
                  options = list(
                    `actions-box` = TRUE,
                    `live-search` = TRUE,
                    `none-selected-text` = "Please select files"
                  )
                )
            ),
            
            # Download Selected Files
            downloadButton("download.folder", "Download Selected Files", class = "btn-success"),
            
            tags$hr()
          ),
          
          fluidRow(
            h4("Alignment Parameters"),
            
            # Threshold Numeric Input wrapped in a styled div
            div(class = "aligned-input",
                numericInput(
                  inputId = "threshold",
                  label = HTML("Threshold Align <a id='info_threshold' href='#' style='text-decoration:none;'><i class='fa fa-question-circle'></i></a>"),
                  value = 0,
                  min = 0,
                  max = 1,
                  step = 0.01
                ),
                bsTooltip("info_threshold", "Set the minimum threshold for alignment.", placement = "right")
            ),
            
            tags$hr()
          ),
          
          fluidRow(
            h4("Metadata Information"),
            div(class = "upload-section",
                uiOutput("metadata_g_csv"),
                uiOutput("metadata_h_csv"),
                uiOutput("metadata_g_file"),
                uiOutput("metadata_h_file"),
                p("log.txt: Record of important alignment details."),
                p("top_costs.csv: The topological cost matrix."),
                p("bio_costs.csv: The biological cost matrix (if provided). Not created unless biological input is given."),
                p("overall_costs.csv: Combination of topological and biological cost matrices. Not created unless biological input is given."),
                p("alignment_list.csv: Complete list of all aligned nodes, with similarity scores in descending order."),
                p("alignment_matrix.csv: Matrix form of the alignment with labels from the two input networks.")
            ),
            tags$hr()
          )
      )
    ),
    
    mainPanel(
      div(class = "summary-section",
          h4("Alignment List"),
          tableOutput("alignment.list")
      )
    )
  )
)



