ResultsTab <- tabPanel(
  "Results",
  sidebarLayout(
    sidebarPanel(
      uiOutput("select.folder"),
      uiOutput("select.file"),
      downloadButton("download.folder", "Download Dataset"),
      hr(),
      # Upload zip files
      fileInput("zipfile", "Upload Zipped Dataset", accept = ".zip"),
      actionButton("unzip", "Unzip")
    ),
    mainPanel(
      verbatimTextOutput("file.content")
    )
  )
)
