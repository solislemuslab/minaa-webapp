options(shiny.maxRequestSize = 10 * 2^20) # raise limit from 5MB default to 10MB

function(input, output) {
  ######## ALIGN TAB ########

  # Display the selected file
  output$align_contentsG <- renderText({
    inFile <- input$align_GFile

    if (is.null(inFile)) {
      return(NULL)
    }

    file_content <- readLines(inFile$datapath)
    paste(file_content, collapse = "\n")
  })

  output$align_contentsH <- renderText({
    inFile <- input$align_HFile

    if (is.null(inFile)) {
      return(NULL)
    }

    file_content <- readLines(inFile$datapath)
    paste(file_content, collapse = "\n")
  })

  output$align_contentsB <- renderText({
    inFile <- input$align_BFile

    if (is.null(inFile)) {
      return(NULL)
    }

    file_content <- readLines(inFile$datapath)
    paste(file_content, collapse = "\n")
  })

  output$alphaOut <- renderPrint({
    input$alphaIn
  })
  output$betaOut <- renderPrint({
    input$betaIn
  })

  # Handle minaa.exe execution
  observeEvent(input$executeAlign, {
    # # TESTING
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
    # include passthrough option
    arg_p <- " -p"
    # include greekstamp option
    arg_g <- " -g"

    args <- paste0("./minaa.exe", arg_G, arg_H, arg_B, arg_a, arg_b, arg_Galias, arg_Halias, arg_p, arg_g)
    # system(args)

    # # Run Visualization
    # if (input$do_vis) {
    #   source("visualize.R")
    #   # Reverse engineer the folder name
    #   result_folder <- paste0("./alignments/", Galias, "-", Halias)
    #   # Append alpha
    #   if (is.null(a) || is.na(a)) {
    #     result_folder <- paste0(result_folder, "-a1")
    #   } else {
    #     result_folder <- paste0(result_folder, "-a", a)
    #   }
    #   # Append beta if appropriate
    #   if (!is.null(B)) {
    #     if (is.null(b) || is.na(b)) {
    #       result_folder <- paste0(result_folder, "-b1")
    #     } else {
    #       result_folder <- paste0(result_folder, "-b", b)
    #     }
    #   }
    #
    #   G_filepath <- paste0(result_folder, "/", Galias, ".csv")
    #   H_filepath <- paste0(result_folder, "/", Halias, ".csv")
    #   A_filepath <- paste0(result_folder, "/", "alignment_matrix.csv")
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

  # Display the selected file
  output$vis_contentsG <- renderText({
    inFile <- input$vis_GFile # RENAME VARS

    if (is.null(inFile)) {
      return(NULL)
    }

    file_content <- readLines(inFile$datapath)
    paste(file_content, collapse = "\n")
  })

  output$vis_contentsH <- renderText({
    inFile <- input$vis_HFile

    if (is.null(inFile)) {
      return(NULL)
    }

    file_content <- readLines(inFile$datapath)
    paste(file_content, collapse = "\n")
  })

  output$vis_contentsA <- renderText({
    inFile <- input$vis_AFile

    if (is.null(inFile)) {
      return(NULL)
    }

    file_content <- readLines(inFile$datapath)
    paste(file_content, collapse = "\n")
  })

  # Handle execution
  observeEvent(input$executeVisualize, {
    G <- input$vis_GFile$datapath
    H <- input$vis_HFile$datapath
    A <- input$vis_AFile$datapath

    # Process G
    if (is.null(G)) {
      print("Error: A value for G must be provided.")
      break # PROBLEM: THIS RESULTS IN CRASH
    }
    # Process H
    if (is.null(H)) {
      print("Error: A value for H must be provided.")
      break
    }
    # Process A
    if (is.null(A)) {
      print("Error: A value for A must be provided.")
      break
    }
    # Run Visualization
    source("visualize.R")
    generate_network_plot(G, H, A)
  })

  # # Download the selected folder
  # output$download.folder <- downloadHandler(
  #   filename = function() {
  #     paste(input$folder.name, ".zip", sep = "")
  #   },
  #   content = function(file) {
  #     zip::zipr(zipfile = file, files = file.path(resultDirectory, input$folder.name), recurse = TRUE)
  #   }
  # )
}
