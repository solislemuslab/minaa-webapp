VisualizeTab <- tabPanel(
  "Visualize",
  sidebarLayout(
    sidebarPanel(
      # Enhanced instruction for running MINNA first
      tags$div(
        style = "font-size: 16px; font-weight: bold; color: #D9534F; margin-bottom: 15px;",
        "Please run MINNA first to generate the required file (Alignment Matrix) before uploading."
      ),    
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
      
      # Size and Degree Parameters
      fluidRow(
        h4("Size and Degree Parameters"),
        tags$details(
          tags$summary("Show/Hide Size and Degree Parameters"),
          column(6,
                 numericInput(
                   "vis_size_aligned", 
                   label = HTML("Size Aligned <a id='info_size_aligned_' href='#' style='text-decoration:none;'><i class='fa fa-question-circle'></i></a>"), 
                   value = 1, 
                   step = 1
                 ),
                 bsTooltip("info_size_aligned_", "Sizes of aligned nodes.", placement = "right")
          ),
          
          column(6,
                 numericInput(
                   "vis_zero_degree", 
                   label = HTML("Degree Align <a id='info_zero_degree_' href='#' style='text-decoration:none;'><i class='fa fa-question-circle'></i></a>"), 
                   value = 0, 
                   step = 1
                 ),
                 bsTooltip("info_zero_degree_", "Minimum degree to show nodes in the graph.", placement = "right")
          ),
          
          column(6,
                 numericInput(
                   "vis_th_align", 
                   label = HTML("Threshold Align <a id='info_th_align_' href='#' style='text-decoration:none;'><i class='fa fa-question-circle'></i></a>"), 
                   value = 0.5, 
                   step = 0.01
                 ),
                 bsTooltip("info_th_align_", "Minimum threshold values required for alignment.", placement = "right")
          ),
          
          column(6,
                 numericInput(
                   "vis_vertex_label_value", 
                   label = HTML("Vertex Label Value <a id='info_vertex_label_value_' href='#' style='text-decoration:none;'><i class='fa fa-question-circle'></i></a>"), 
                   value = 0.5, 
                   step = 0.01
                 ),
                 bsTooltip("info_vertex_label_value_", "Size of the node label", placement = "right")
          ),
          
          tags$hr()
        )
      ),
      
      # Color Options
      fluidRow(
        h4("Color Options"),
        tags$details(
          tags$summary("Show/Hide Color Options"),
          column(6,
                 colourInput("vis_node_G_color", "Color for Nodes in G", value = "#3F8C61")  # Unique ID
          ),
          column(6,
                 colourInput("vis_node_H_color", "Color for Nodes in H", value = "#11A0D9")  # Unique ID
          ),
          column(6,
                 colourInput("vis_edge_G_color", "Color for Edges in G", value = "grey")  # Unique ID
          ),
          column(6,
                 colourInput("vis_edge_H_color", "Color for Edges in H", value = "grey")  # Unique ID
          ),
          column(6,
                 colourInput("vis_aligned_G_color", "Color for Aligned Nodes in G", value = "#F2B705")  # Unique ID
          ),
          column(6,
                 colourInput("vis_aligned_H_color", "Color for Aligned Nodes in H", value = "#F2B705")  # Unique ID
          ),
          column(12,
                 colourInput("vis_line_GH_color", "Color for alignments between G and H", value = "#9491D9")  # Unique ID
          ),
          tags$hr()  # Horizontal line for separation
        )
      ),
      
      # Run button
      fluidRow(
        actionButton("vis_submitInputs", label = "Run", class = "btn-primary", width = "100%")  # Unique ID
      )
    ),
    
    mainPanel(
      # Set the style of the verbatimTextOutput box
      tags$head(
        tags$style(
          HTML(".my-verbatim { max-height: 200px; overflow-y: auto; }")
        )
      ),
      
      # Display uploaded data previews (optional)
      verbatimTextOutput("vis_vis_GTable"),  # Unique ID
      verbatimTextOutput("vis_vis_HTable"),  # Unique ID
      verbatimTextOutput("vis_vis_ATable"),  # Unique ID
      
      # Network plot output
      plotOutput("vis_networkPlot", height = "1000px", width = "1000px"),  # Unique ID
      
      # Conditional panel to show download button only when plot is generated
      conditionalPanel(
        condition = "output.vis_plotGenerated == true",  # Unique ID
        fluidRow(
          column(6, 
                 selectInput("vis_downloadFormat", "Select Format", 
                             choices = c("PNG", "JPEG"), selected = "PNG")  # Unique ID
          ),
          column(6, 
                 downloadButton("vis_downloadPlot", "Download Plot")  # Unique ID
          )
        )
      )
    )
  )
)
