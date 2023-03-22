options(shiny.maxRequestSize = 10*2^20) # raise limit from 5MB default to 10MB

function(input, output) {
  
  ######## ALIGN TAB ########
  
  # https://github.com/rstudio/shiny-examples/tree/main/066-upload-file
  output$contents1 <- renderTable({
    inFile1 <- input$file1
    
    if (is.null(inFile1))
      return(NULL)
    
    read.csv(inFile1$datapath, header = input$header,
             sep = input$sep, quote = input$quote)
  })
  
  output$contents2 <- renderTable({
    inFile2 <- input$file2
    
    if (is.null(inFile2))
      return(NULL)
    
    read.csv(inFile2$datapath, header = input$header,
             sep = input$sep, quote = input$quote)
  })
  
  output$contents3 <- renderTable({
    inFile3 <- input$file3
    
    if (is.null(inFile3))
      return(NULL)
    
    read.csv(inFile3$datapath, header = input$header,
             sep = input$sep, quote = input$quote)
  })
  
  output$alphaOut <- renderPrint({ input$alphaIn })
  output$betaOut <- renderPrint({ input$betaIn })
  
  # Handle minaa.exe execution
  observeEvent(input$submitInputs, {
    G <- input$file1$datapath
    H <- input$file2$datapath
    B <- input$file3$datapath
    a <- input$alphaIn
    b <- input$betaIn
    
    # Process G
    if (is.null(G)) {
      print("Error: A value for G must be provided.")
      break
    }
    # Process H
    if (is.null(H)) {
      print("Error: a value for H must be provided.")
      break
    }
    # Process B
    if (is.null(B)) {
      B <- ""
    }
    else {
      B <- paste0(" -B=", B)
    }
    # Process a
    if (is.null(a) || is.na(a)) {
      a <- ""
    }
    else {
      a <- paste0(" -a=", a)
    }
    # Process b
    if (is.null(b) || is.na(b)) {
      b <- ""
    }
    else {
      b <- paste0(" -b=", b)
    }
    
    args <- paste0("./minaa.exe ", G, " ", H, B, a, b)
    system(args)
  })
  
  ######## RESULTS TAB ########
  
  # Handle result selection
  resultDirectory <- './alignments'
  output$select.folder <-
    renderUI(expr = selectInput(inputId = 'folder.name',
                                label = 'Dataset',
                                choices = list.dirs(path = resultDirectory,
                                                    full.names = FALSE,
                                                    recursive = FALSE)))
  output$select.file <-
    renderUI(expr = selectInput(inputId = 'file.name',
                                label = 'File',
                                choices = list.files(path = file.path(resultDirectory,
                                                                      input$folder.name))))
  
  # Display the selected file
  output$file.content <- renderText({
    file_path <- file.path(resultDirectory, input$folder.name, input$file.name)
    file_content <- readLines(file_path)
    paste(file_content, collapse = '\n')
  })
  
  # Download the selected folder
  output$download.folder <- downloadHandler(
    filename = function() {
      paste(input$folder.name, ".zip", sep = "")
    },
    content = function(file) {
      zip::zipr(zipfile = file, files = file.path(resultDirectory, input$folder.name), recurse = TRUE)
    }
  )
  
  # Upload Dataset
  observeEvent(input$unzip, {
    
    if (is.null(input$zipfile)) {
      return()
    }
    
    unzip_dir <- "alignments"
    file_name <- tools::file_path_sans_ext(basename(input$zipfile$name))
    unzip_dir <- file.path(unzip_dir, file_name)
    unzip(input$zipfile$datapath, exdir = unzip_dir, junkpaths = TRUE)
    
    # Refresh dataset dropdown
    resultDirectory <- './alignments'
    output$select.folder <-
      renderUI(expr = selectInput(inputId = 'folder.name',
                                  label = 'Dataset',
                                  choices = list.dirs(path = resultDirectory,
                                                      full.names = FALSE,
                                                      recursive = FALSE)))
    
    # Check resulting files to make sure formats are correct?
    # Check resulting files to make sure not too big?
  })
  
}
