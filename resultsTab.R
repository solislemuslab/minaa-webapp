ResultsTab <- tabPanel(
  "Results",
  sidebarLayout(
    sidebarPanel(
      uiOutput("select.folder"),
      
      # PickerInput for multiple file selection
      pickerInput(
        inputId = "file.name",
        label = "File",
        choices = NULL,  # To be dynamically populated
        multiple = TRUE,  # Allow multiple file selection
        options = list(
          `actions-box` = TRUE,   # Select/deselect all option
          `live-search` = TRUE,    # Enable search within the dropdown
          `none-selected-text` = "Please select files"  # Custom placeholder
        )
      ),
      
      # Download selected files
      downloadButton("download.folder", "Download Selected Files"),
      
      hr(),
      
      # Numeric input for filtering threshold
      numericInput(
        inputId = "threshold",
        label = "Threshold Align",
        value = 0,  # Default threshold value
        min = 0,    # Minimum allowed value
        max = 1,   # Maximum allowed value (adjust as per your needs)
        step = 0.01
      ),
      
      hr(),
      
      h4("Metadata Information"),
      
      # Dynamic placeholders for g.csv and h.csv (based on the uploaded names)
      uiOutput("metadata_g_csv"),
      uiOutput("metadata_h_csv"),
      
      # Dynamic placeholders for G and H files
      uiOutput("metadata_g_file"),
      uiOutput("metadata_h_file"),
      
      # Static Information for log and cost files
      p("log.txt: Record of important alignment details."),
      p("top_costs.csv: The topological cost matrix."),
      p("bio_costs.csv: The biological cost matrix (if provided). Not created unless biological input is given."),
      p("overall_costs.csv: Combination of topological and biological cost matrices. Not created unless biological input is given."),
      p("alignment_list.csv: Complete list of all aligned nodes, with similarity scores in descending order. The first row contains the total cost of the alignment."),
      p("alignment_matrix.csv: Matrix form of the alignment with labels from the two input networks."),
      
      hr()
    ),
    mainPanel(
      # Display the alignment list
      h4("Alignment List"),
      tableOutput("alignment.list")
    )
  )
)
