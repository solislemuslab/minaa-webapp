options(shiny.maxRequestSize = 10 * 2^20) # raise limit from 5MB default to 10MB

function(input, output) {
  ######## ALIGN TAB ########

  # Display the selected file
  output$contents1 <- renderText({
    inFile1 <- input$align_GFile # RENAME VARS

    if (is.null(inFile1)) {
      return(NULL)
    }

    file_content <- readLines(inFile1$datapath)
    paste(file_content, collapse = "\n")
  })

  output$contents2 <- renderText({
    inFile2 <- input$align_HFile

    if (is.null(inFile2)) {
      return(NULL)
    }

    file_content <- readLines(inFile2$datapath)
    paste(file_content, collapse = "\n")
  })

  output$contents3 <- renderText({
    inFile3 <- input$align_BFile

    if (is.null(inFile3)) {
      return(NULL)
    }

    file_content <- readLines(inFile3$datapath)
    paste(file_content, collapse = "\n")
  })

  output$alphaOut <- renderPrint({
    input$alphaIn
  })
  output$betaOut <- renderPrint({
    input$betaIn
  })

  # Handle minaa.exe execution
  observeEvent(input$submitInputs, {
    # TEST
    # source("visualize.R")
    # generate_network_plot(
    #   "./alignments/G-10-0.1-1-G-10-0.1-2/G-10-0.1-1.csv",
    #   "./alignments/G-10-0.1-1-G-10-0.1-2/G-10-0.1-2.csv",
    #   "./alignments/G-10-0.1-1-G-10-0.1-2/alignment_matrix.csv")
    # break

    G <- input$align_GFile$datapath
    H <- input$align_HFile$datapath
    B <- input$align_BFile$datapath
    a <- input$alphaIn
    b <- input$betaIn
    Galias <- tools::file_path_sans_ext(input$align_GFile$name)
    Halias <- tools::file_path_sans_ext(input$align_HFile$name)

    # Process G
    if (is.null(G)) {
      print("Error: A value for G must be provided.")
      break # PROBLEM: THIS RESULTS IN CRASH
    } else {
      arg_G <- paste0(" ", G)
    }
    # Process H
    if (is.null(H)) {
      print("Error: A value for H must be provided.")
      break
    } else {
      arg_H <- paste0(" ", H)
    }
    # Process B
    if (is.null(B)) {
      arg_B <- ""
    } else {
      arg_B <- paste0(" -B=", B)
    }
    # Process a
    if (is.null(a) || is.na(a)) {
      arg_a <- ""
    } else {
      arg_a <- paste0(" -a=", a)
    }
    # Process b
    if (is.null(b) || is.na(b)) {
      arg_b <- ""
    } else {
      arg_b <- paste0(" -b=", b)
    }
    # Process G Alias
    if (is.null(Galias) || is.na(Galias)) {
      arg_Galias <- ""
    } else {
      arg_Galias <- paste0(" -Galias=", Galias)
    }
    # Process H Alias
    if (is.null(Halias) || is.na(Halias)) {
      arg_Halias <- ""
    } else {
      arg_Halias <- paste0(" -Halias=", Halias)
    }
    # process p
    arg_p <- " -p"
    # process g
    arg_g <- " -g"

    args <- paste0("./minaa.exe", arg_G, arg_H, arg_B, arg_a, arg_b, arg_Galias, arg_Halias, arg_p, arg_g)
    system(args)

    # # Run Visualization // NEED TO UPDATE FOR GREEKSTAMPING
    # if (input$do_vis) {
    #   source("visualize.R")
    #   result_folder <- paste0("./alignments/", Galias, "-", Halias, "/")
    #   G_filepath <- paste0(result_folder, Galias, ".csv")
    #   H_filepath <- paste0(result_folder, Halias, ".csv")
    #   A_filepath <- paste0(result_folder, "alignment_matrix.csv")
    #   generate_network_plot(G_filepath, H_filepath, A_filepath)
    # }
  })

  ######## RESULTS TAB ########

  resultDirectory <- "./alignments"

  # Handle result selection
  output$select.folder <-
    renderUI(expr = selectInput(
      inputId = "folder.name",
      label = "Result Folder",
      choices = list.dirs(
        path = resultDirectory,
        full.names = FALSE,
        recursive = FALSE
      )
    ))
  output$select.file <-
    renderUI(expr = selectInput(
      inputId = "file.name",
      label = "File",
      choices = list.files(path = file.path(
        resultDirectory,
        input$folder.name
      ))
    ))

  # Display the selected file
  output$file.content <- renderText({
    file_path <- file.path(resultDirectory, input$folder.name, input$file.name)
    file_content <- readLines(file_path)
    paste(file_content, collapse = "\n")
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

  ######## VISUALIZE TAB ########
  visualizeDirectory <- "./alignments"

  # Handle result selection
  # output$select.visfolder <-
  #   renderUI(expr = selectInput(inputId = 'visfolder.name',
  #                               label = 'Dataset',
  #                               choices = list.dirs(path = visualizeDirectory,
  #                                                   full.names = FALSE,
  #                                                   recursive = FALSE)))
  # # output$select.file <-
  #   renderUI(expr = selectInput(inputId = 'file.name',
  #                               label = 'File',
  #                               choices = list.files(path = file.path(visualizeDirectory,
  #                                                                     input$folder.name))))

  # Display the selected file
  # output$file.content <- renderText({
  #   file_path <- file.path(visualizeDirectory, input$folder.name, input$file.name)
  #   file_content <- readLines(file_path)
  #   paste(file_content, collapse = '\n')
  # })

  # # Download the selected folder
  # output$download.folder <- downloadHandler(
  #   filename = function() {
  #     paste(input$folder.name, ".zip", sep = "")
  #   },
  #   content = function(file) {
  #     zip::zipr(zipfile = file, files = file.path(resultDirectory, input$folder.name), recurse = TRUE)
  #   }
  # )
  #
  # # Upload Dataset
  # observeEvent(input$unzip, {
  #
  #   if (is.null(input$zipfile)) {
  #     return()
  #   }
  #
  #   unzip_dir <- "alignments"
  #   file_name <- tools::file_path_sans_ext(basename(input$zipfile$name))
  #   unzip_dir <- file.path(unzip_dir, file_name)
  #   unzip(input$zipfile$datapath, exdir = unzip_dir, junkpaths = TRUE)
  #
  #   # Refresh dataset dropdown
  #   resultDirectory <- './alignments'
  #   output$select.folder <-
  #     renderUI(expr = selectInput(inputId = 'folder.name',
  #                                 label = 'Dataset',
  #                                 choices = list.dirs(path = resultDirectory,
  #                                                     full.names = FALSE,
  #                                                     recursive = FALSE)))
  # })
}
