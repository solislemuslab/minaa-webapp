ResultsTab <- tabPanel(
  "Results",
  sidebarLayout(
    sidebarPanel(
      uiOutput("select.folder"),
      uiOutput("select.file"),
      downloadButton("download.folder", "Download Dataset")
    ),
    mainPanel(
      verbatimTextOutput("file.content")
    )
  )
)
