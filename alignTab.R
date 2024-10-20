AlignTab <- tabPanel(
  "Run",
  sidebarLayout(
    sidebarPanel(
      fluidRow(
        h4("Upload Networks and Data"),
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
        ),
        
        # Checkbox for biological similarity matrix
        checkboxInput(
          "is_bio_matrix", 
          "Is the input a biological similarity matrix?", 
          value = FALSE
        ),
        
        # Generate visual checkbox
        checkboxInput("do_vis", "Generate Visual", TRUE),
        
        tags$hr()  # Horizontal line for separation
      ),
      
      # Alignment parameters in a collapsible section
      fluidRow(
        h4("Alignment Parameters"),
        tags$details(
          tags$summary("Show/Hide Alignment Parameters"),
          column(6,
                 numericInput(
                   "alphaIn", 
                   label = "\U03B1 (Alpha)", 
                   value = 1, 
                   min = 0, 
                   max = 1, 
                   step = 0.01
                 )
          ),
          column(6,
                 numericInput(
                   "betaIn", 
                   label = "\U03B2 (Beta)", 
                   value = 1, 
                   min = 0, 
                   max = 1, 
                   step = 0.01
                 )
          ),
          
          tags$hr()  # Horizontal line for separation
        )
      ),
      
      # Size and Degree Parameters
      fluidRow(
        h4("Size and Degree Parameters"),
        tags$details(
          tags$summary("Show/Hide Size and Degree Parameters"),
          column(6,
                 numericInput(
                   "size_aligned", 
                   "Size Aligned", 
                   value = 1, 
                   step = 1
                 )
          ),
          column(6,
                 numericInput(
                   "zero_degree", 
                   "Degree Align", 
                   value = 0, 
                   step = 1
                 )
          ),
          column(6,
                 numericInput(
                   "th_align", 
                   "Threshold Align", 
                   value = 0.5, 
                   step = 0.01
                 )
          ),
          column(6,
                 numericInput(
                   "vertex_label_value", 
                   "Vertex Label Value", 
                   value = 0.5, 
                   step = 0.01
                 )
          ),
          
          tags$hr()  # Horizontal line for separation
        )
      ),
      
      # Color Options
      fluidRow(
        h4("Color Options"),
        tags$details(
          tags$summary("Show/Hide Color Options"),
          column(6,
                 colourInput("node_G_color", "Color for Nodes in G", value = "#FF0000")
          ),
          column(6,
                 colourInput("node_H_color", "Color for Nodes in H", value = "#00FF00")
          ),
          column(6,
                 colourInput("edge_G_color", "Color for Edges in G", value = "#0000FF")
          ),
          column(6,
                 colourInput("edge_H_color", "Color for Edges in H", value = "#FFFF00")
          ),
          column(6,
                 colourInput("aligned_G_color", "Color for Aligned Nodes in G", value = "#11A0D9")
          ),
          column(6,
                 colourInput("aligned_H_color", "Color for Aligned Nodes in H", value = "#44AA99")
          ),
          column(12,
                 colourInput("line_GH_color", "Color for alignments between G and H", value = "#000000")
          ),
          
          tags$hr()  # Horizontal line for separation
        )
      ),
      
      # Run button
      fluidRow(
        actionButton("submitInputs", label = "Run", class = "btn-primary", width = "100%")
      )
    ),
    
    mainPanel(
      tags$head(
        tags$style(
          HTML(".my-verbatim { max-height: 200px; overflow-y: auto; }")
        )
      ),
      plotOutput("networkPlot", height = "1000px", width = "1000px"),  # Adjusted plot dimensions
      
      # Conditional panel to show download button only when plot is generated
      conditionalPanel(
        condition = "output.plotGenerated == true",  # Renders only when the plot is generated
        fluidRow(
          column(6, 
                 selectInput("downloadFormat", "Select Format", 
                             choices = c("PNG", "JPEG"), selected = "PNG")
          ),
          column(6, 
                 downloadButton("downloadPlot", "Download Plot")
          )
        )
      )
    )
  )
)
