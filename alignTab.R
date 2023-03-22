AlignTab <- tabPanel("Align",
         sidebarLayout(
           sidebarPanel(
             fluidRow(
               # Input network G
               fileInput(
                 'file1',
                 'Upload network G',
                 accept = c(
                   'text/csv',
                   'text/comma-separated-values',
                   'text/tab-separated-values',
                   'text/plain',
                   '.csv',
                   '.tsv'
                 ),
                 placeholder = "No file selected (required)",
                 width = "100%"
               ),
               p(style="margin: -16px"),
               # Input network H
               fileInput(
                 'file2',
                 'Upload network H',
                 accept = c(
                   'text/csv',
                   'text/comma-separated-values',
                   'text/tab-separated-values',
                   'text/plain',
                   '.csv',
                   '.tsv'
                 ),
                 placeholder = "No file selected (required)",
                 width = "100%"
               ),
               p(style="margin: -16px"),
               # Input biological data
               fileInput(
                 'file3',
                 'Upload biological data',
                 accept = c(
                   'text/csv',
                   'text/comma-separated-values',
                   'text/tab-separated-values',
                   'text/plain',
                   '.csv',
                   '.tsv'
                 ),
                 placeholder = "No file selected (optional)",
                 width = "100%"
               ),
               p(style="margin: -16px")
             ),
             fluidRow(
               # Specify input format
               column(
                 6,
                 checkboxInput('header', 'Header', TRUE),
                 radioButtons('sep', 'Separator',
                              c(
                                Comma = ',',
                                Semicolon = ';',
                                Tab = '\t'
                              ),
                              ','),
                 radioButtons(
                   'quote',
                   'Quote',
                   c(
                     None = '',
                     'Double Quote' = '"',
                     'Single Quote' = "'"
                   ),
                   '"'
                 )
               ),
               # Specify balancing parameters
               column(
                 6,
                 numericInput(
                   "alphaIn",
                   label = "\U03B1",
                   value = 1,
                   min = 0,
                   max = 1,
                   step = 0.01,
                   width = "84px"
                 ),
                 numericInput(
                   "betaIn",
                   label = "\U03B2",
                   value = 1,
                   min = 0,
                   max = 1,
                   step = 0.01,
                   width = "84px"
                 ),
                 # Submit Button
                 actionButton("submitInputs", label = "Run", width = "84px")
               )
             )
           ),
           mainPanel(
             tableOutput('contents1')
           )
         ))