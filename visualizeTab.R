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
      
      # Size and Degree Parameters
      fluidRow(
        h4("Size and Degree Parameters"),
        tags$details(
          tags$summary("Show/Hide Size and Degree Parameters"),
          column(6,
                 numericInput(
                   "vis_size_aligned",  # Unique ID with prefix "vis_"
                   "Size Aligned", 
                   value = 1, 
                   step = 1
                 )
          ),
          column(6,
                 numericInput(
                   "vis_zero_degree",  # Unique ID with prefix "vis_"
                   "Degree Align", 
                   value = 0, 
                   step = 1
                 )
          ),
          column(6,
                 numericInput(
                   "vis_th_align",  # Unique ID with prefix "vis_"
                   "Threshold Align", 
                   value = 0.5, 
                   step = 0.01
                 )
          ),
          column(6,
                 numericInput(
                   "vis_vertex_label_value",  # Unique ID with prefix "vis_"
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
                 colourInput("vis_node_G_color", "Color for Nodes in G", value = "#FF0000")  # Unique ID
          ),
          column(6,
                 colourInput("vis_node_H_color", "Color for Nodes in H", value = "#00FF00")  # Unique ID
          ),
          column(6,
                 colourInput("vis_edge_G_color", "Color for Edges in G", value = "#0000FF")  # Unique ID
          ),
          column(6,
                 colourInput("vis_edge_H_color", "Color for Edges in H", value = "#FFFF00")  # Unique ID
          ),
          column(6,
                 colourInput("vis_aligned_G_color", "Color for Aligned Nodes in G", value = "#11A0D9")  # Unique ID
          ),
          column(6,
                 colourInput("vis_aligned_H_color", "Color for Aligned Nodes in H", value = "#44AA99")  # Unique ID
          ),
          column(12,
                 colourInput("vis_line_GH_color", "Color for alignments between G and H", value = "#000000")  # Unique ID
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
