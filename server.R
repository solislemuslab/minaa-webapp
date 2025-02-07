options(shiny.maxRequestSize = 10 * 2^20) # raise limit from 5MB default to 10MB
library(colourpicker)
library(jpeg)
library(png)
library(igraph)
library(plotly)
library(htmlwidgets)
library(webshot) # install.packages("webshot")
webshot::install_phantomjs() #

plot_aligned_networks <- function(adj_G, adj_A, alignment_GA, th_align, zero_degree, size_aligned,
                                  node_G_color, node_H_color, edge_G_color, edge_H_color, line_GH_color, aligned_G_color, aligned_H_color) {
  # Set name limit to 3
  name_limit <- 9

  truncate_names <- function(names, prefix, name_limit) {
    # Determine which names exceed the limit
    is_truncated <- nchar(names) > name_limit

    # Only truncate names that exceed the limit, keep others as is
    truncated <- ifelse(is_truncated, paste0(prefix, seq_along(names)), names)

    # Return a data frame with original and truncated names, along with truncation status
    data.frame(
      Original_Name = names,
      Truncated_Name = truncated,
      Is_Truncated = is_truncated
    )
  }

  # Create graph objects from adjacency matrices
  graph_G <- graph_from_adjacency_matrix(adj_G, mode = "undirected")
  graph_A <- graph_from_adjacency_matrix(adj_A, mode = "undirected")

  original_names_G <- rownames(adj_G)
  original_names_A <- rownames(adj_A)

  # Apply truncation logic to G and A
  name_mapping_G <- truncate_names(original_names_G, "g", name_limit)
  name_mapping_A <- truncate_names(original_names_A, "h", name_limit)

  # Extract truncated names for graph objects
  truncated_names_G <- name_mapping_G$Truncated_Name
  truncated_names_A <- name_mapping_A$Truncated_Name

  # Set names in the graph objects
  V(graph_G)$name <- truncated_names_G
  V(graph_A)$name <- truncated_names_A

  # Identify aligned nodes based on alignment threshold
  alignment_indices <- which(alignment_GA >= th_align, arr.ind = TRUE)
  aligned_nodes_G <- V(graph_G)$name[alignment_indices[, 1]]
  aligned_nodes_A <- V(graph_A)$name[alignment_indices[, 2]]

  # Remove zero-degree nodes, excluding aligned nodes
  graph_G <- delete.vertices(graph_G, V(graph_G)[degree(graph_G) < zero_degree & !(V(graph_G)$name %in% aligned_nodes_G)])
  graph_A <- delete.vertices(graph_A, V(graph_A)[degree(graph_A) < zero_degree & !(V(graph_A)$name %in% aligned_nodes_A)])

  # Re-identify aligned node indices after removing nodes
  aligned_indices_G <- match(aligned_nodes_G, V(graph_G)$name)
  aligned_indices_A <- match(aligned_nodes_A, V(graph_A)$name)
  aligned_indices_G <- aligned_indices_G[!is.na(aligned_indices_G)]
  aligned_indices_A <- aligned_indices_A[!is.na(aligned_indices_A)]

  # Circular Layout for G and A with a moderate radius
  radius <- 7 # Moderate radius for each circle to spread nodes without making the layout too large
  layout_G <- layout_in_circle(graph_G) * radius - cbind(rep(9, nrow(layout_in_circle(graph_G))), rep(0, nrow(layout_in_circle(graph_G)))) # Shift G to the left
  layout_A <- layout_in_circle(graph_A) * radius + cbind(rep(9, nrow(layout_in_circle(graph_A))), rep(0, nrow(layout_in_circle(graph_A)))) # Shift A to the right

  # Adjust aligned nodes to be directly opposite each other on each circle
  num_aligned <- min(length(aligned_indices_G), length(aligned_indices_A))
  angle_step <- pi / (num_aligned + 1)
  start_angle <- pi / 2

  for (i in seq_along(aligned_indices_G)) {
    angle <- start_angle - (i * angle_step)
    layout_G[aligned_indices_G[i], ] <- c(cos(angle) * radius - 9, sin(angle) * radius) # Left circle
    layout_A[aligned_indices_A[i], ] <- c(-cos(angle) * radius + 9, sin(angle) * radius) # Right circle
  }

  # Node data frames for Plotly with conditional color assignment
  nodes_G <- data.frame(
    x = layout_G[, 1],
    y = layout_G[, 2],
    name = V(graph_G)$name,
    color = ifelse(V(graph_G)$name %in% aligned_nodes_G, aligned_G_color, node_G_color),
    size = ifelse(V(graph_G)$name %in% aligned_nodes_G, size_aligned, 6)
  )

  nodes_A <- data.frame(
    x = layout_A[, 1],
    y = layout_A[, 2],
    name = V(graph_A)$name,
    color = ifelse(V(graph_A)$name %in% aligned_nodes_A, aligned_H_color, node_H_color),
    size = ifelse(V(graph_A)$name %in% aligned_nodes_A, size_aligned, 6)
  )

  # Edge data for edges within G
  edgelist_G <- get.edgelist(graph_G, names = FALSE)
  edges_G <- data.frame(
    x = layout_G[edgelist_G[, 1], 1],
    y = layout_G[edgelist_G[, 1], 2],
    xend = layout_G[edgelist_G[, 2], 1],
    yend = layout_G[edgelist_G[, 2], 2]
  )

  # Edge data for edges within A
  edgelist_A <- get.edgelist(graph_A, names = FALSE)
  edges_A <- data.frame(
    x = layout_A[edgelist_A[, 1], 1],
    y = layout_A[edgelist_A[, 1], 2],
    xend = layout_A[edgelist_A[, 2], 1],
    yend = layout_A[edgelist_A[, 2], 2]
  )

  # Edge data for aligned edges between G and A
  edges_aligned <- data.frame(
    x = layout_G[aligned_indices_G, 1],
    y = layout_G[aligned_indices_G, 2],
    xend = layout_A[aligned_indices_A, 1],
    yend = layout_A[aligned_indices_A, 2]
  )

  # Initialize Plotly plot
  p <- plot_ly()

  # Add edges within G with edge_G_color
  p <- p %>%
    add_segments(
      data = edges_G, x = ~x, y = ~y, xend = ~xend, yend = ~yend,
      line = list(color = edge_G_color, width = 0.3), hoverinfo = "none", showlegend = FALSE
    )

  # Add edges within A with edge_H_color
  p <- p %>%
    add_segments(
      data = edges_A, x = ~x, y = ~y, xend = ~xend, yend = ~yend,
      line = list(color = edge_H_color, width = 0.3), hoverinfo = "none", showlegend = FALSE
    )

  # Add aligned edges between G and A with line_GH_color
  p <- p %>%
    add_segments(
      data = edges_aligned, x = ~x, y = ~y, xend = ~xend, yend = ~yend,
      line = list(color = line_GH_color, width = 1.5), hoverinfo = "none", showlegend = FALSE
    )

  # Add nodes from G with explicit colors
  p <- p %>%
    add_trace(
      data = nodes_G, x = ~x, y = ~y, type = "scatter", mode = "markers+text",
      text = ~name, textposition = "top center", hoverinfo = "text",
      marker = list(color = nodes_G$color, size = nodes_G$size),
      hoverlabel = list(
        bgcolor = "white", # Background color of hover label
        bordercolor = "black", # Border color
        font = list(size = 12, family = "Arial") # Font settings
      ),
      showlegend = FALSE
    )

  # Add nodes from A with explicit colors
  p <- p %>%
    add_trace(
      data = nodes_A, x = ~x, y = ~y, type = "scatter", mode = "markers+text",
      text = ~name, textposition = "top center", hoverinfo = "text",
      marker = list(color = nodes_A$color, size = nodes_A$size),
      hoverlabel = list(
        bgcolor = "white",
        bordercolor = "black",
        font = list(size = 12, family = "Arial")
      ),
      showlegend = FALSE
    )

  # Add titles above networks G and H using annotations
  p <- p %>%
    layout(
      title = "Aligned Network Visualization",
      xaxis = list(visible = FALSE),
      yaxis = list(visible = FALSE),
      showlegend = FALSE,
      annotations = list(
        list(
          x = -9, y = max(layout_G[, 2]) + 1, text = "Network G", showarrow = FALSE,
          xref = "x", yref = "y", font = list(size = 14, color = "black")
        ),
        list(
          x = 9, y = max(layout_A[, 2]) + 1, text = "Network H", showarrow = FALSE,
          xref = "x", yref = "y", font = list(size = 14, color = "black")
        )
      )
    )

  return(list(plot = p, name_mapping_G = name_mapping_G, name_mapping_A = name_mapping_A))
}

function(input, output, session) {
  ######## RUN TAB ########
  plotGenerated <- reactiveVal(FALSE)
  output_dir <- "alignments/"
  hidden_temp_dir <- ".temp"
  # alignment_list_filepath <- "path/to/your/alignment_list.csv"

  # Ensure the hidden directory exists
  if (!dir.exists(hidden_temp_dir)) {
    dir.create(hidden_temp_dir)
  }

  # Reactive values to store matrices for use in both plot and download
  reactiveData <- reactiveValues(
    adj_G = NULL,
    adj_A = NULL,
    alignment_GA = NULL,
    alignment_summary = NULL,
    alignment_list = NULL,
  )

  # Display the content of the selected file G
  output$contents1 <- renderText({
    inFile1 <- input$align_GFile

    if (is.null(inFile1)) {
      return("No file for G selected")
    }
  })

  # Display the content of the selected file H
  output$contents2 <- renderText({
    inFile2 <- input$align_HFile

    if (is.null(inFile2)) {
      return("No file for H selected")
    }
  })

  # Handle the execution on clicking submit button
  observeEvent(input$submitInputs, {
    # Validation checks for file uploads
    if (is.null(input$align_GFile)) {
      showNotification("Error: Please upload a file for Network G.", type = "error", duration = 5)
      return() # Stop execution if validation fails
    }

    if (is.null(input$align_HFile)) {
      showNotification("Error: Please upload a file for Network H.", type = "error", duration = 5)
      return() # Stop execution if validation fails
    }

    # Copy uploaded files to the hidden_temp_dir with their original names
    G <- file.path(hidden_temp_dir, input$align_GFile$name)
    H <- file.path(hidden_temp_dir, input$align_HFile$name)

    file.copy(input$align_GFile$datapath, G, overwrite = TRUE)
    file.copy(input$align_HFile$datapath, H, overwrite = TRUE)

    # Get file paths and user inputs
    # G <- input$align_GFile$name
    # print(G)
    # H <- input$align_HFile$name
    B <- input$align_BFile$name # Optional
    a <- input$alphaIn
    b <- input$betaIn

    # print(G)

    # Build the arguments for the system call
    arg_G <- paste0(" ", G)
    arg_H <- paste0(" ", H)
    arg_B <- ifelse(is.null(B), "", paste0(" -B=", B)) # B is optional
    arg_a <- ifelse(is.null(a) || is.na(a), "", paste0(" -a=", a))
    arg_b <- ifelse(is.null(b) || is.na(b), "", paste0(" -b=", b))
    arg_s <- ifelse(input$matrix_type == "similarity", " -s", "")
    arg_p <- " -p" # Assuming -p is always required

    args <- paste0("./minaa.exe", arg_G, arg_H, arg_B, arg_a, arg_b, arg_s, arg_p)
    result <- system(args, intern = TRUE) # Capture output for debugging

    # Check for failure by searching for specific success indicators in result
    if (any(grepl("ALIGNMENT COMPLETED", result))) {
      showNotification("minaa.exe has been executed successfully.", type = "message")
    } else {
      showNotification("Error running minaa.exe", type = "error")
      return(NULL)
    }

    # Generate and render the aligned network plot
    if (input$do_vis) {
      # Load the G and H adjacency matrices (assuming CSV format)
      reactiveData$adj_G <- as.matrix(read.csv(G, row.names = 1))
      reactiveData$adj_A <- as.matrix(read.csv(H, row.names = 1))

      alignment_dir <- sprintf("%s-%s", tools::file_path_sans_ext(basename(G)), tools::file_path_sans_ext(basename(H)))
      alignment_matrix_filepath <- file.path(output_dir, alignment_dir, "alignment_matrix.csv")
      alignment_list_filepath <- file.path(output_dir, alignment_dir, "alignment_list.csv")

      # Load the alignment matrix from the output file generated by minaa.exe
      if (!file.exists(alignment_matrix_filepath)) {
        showNotification("Error: alignment_matrix.csv not found.", type = "error")
        return(NULL)
      }

      reactiveData$alignment_GA <- as.matrix(read.csv(alignment_matrix_filepath, row.names = 1))

      # reactiveData$alignment_list <- as.matrix(read.csv(alignment_list_filepath, header = TRUE))

      alignment_list_raw <- read.csv(alignment_list_filepath, header = FALSE)
      total_cost <- as.numeric(alignment_list_raw[1, 1]) # Extract the first cell value as total_cost

      reactiveData$alignment_list <- as.matrix(read.csv(alignment_list_filepath, header = TRUE))
      # print(reactiveData$alignment_list)

      # Get user-defined parameters for the plot
      th_align <- input$th_align
      zero_degree <- input$zero_degree
      # vertex_label_value <- input$vertex_label_value
      size_aligned <- input$size_aligned
      node_G_color <- input$node_G_color
      node_H_color <- input$node_H_color
      edge_G_color <- input$edge_G_color
      edge_H_color <- input$edge_H_color
      line_GH_color <- input$line_GH_color
      aligned_G_color <- input$aligned_G_color # Get color for aligned nodes in G
      aligned_H_color <- input$aligned_H_color # Get color for aligned nodes in H

      # Track plot generation status
      plotGenerated <- reactiveVal(FALSE)

      # Render the Plotly plot
      output$networkPlot <- renderPlotly({
        tryCatch(
          {
            # Run the plot_aligned_networks function
            result <- plot_aligned_networks(
              adj_G = reactiveData$adj_G,
              adj_A = reactiveData$adj_A,
              alignment_GA = reactiveData$alignment_GA,
              th_align = input$th_align,
              zero_degree = input$zero_degree,
              # vertex_label_value = input$vertex_label_value,
              size_aligned = input$size_aligned,
              node_G_color = input$node_G_color,
              node_H_color = input$node_H_color,
              edge_G_color = input$edge_G_color,
              edge_H_color = input$edge_H_color,
              line_GH_color = input$line_GH_color,
              aligned_G_color = input$aligned_G_color,
              aligned_H_color = input$aligned_H_color
            )

            # Store the plot and set the plot generation status to TRUE
            reactiveData$plot <- result$plot
            reactiveData$name_mapping_G <- result$name_mapping_G
            reactiveData$name_mapping_A <- result$name_mapping_A
            plotGenerated(TRUE) # Set plotGenerated to TRUE once the plot is generated

            # Show notification when the plot is generated
            showNotification("Plot generated successfully.", type = "message")

            result$plot
          },
          error = function(e) {
            print(paste("Error in renderPlotly:", e$message))
            plotGenerated(FALSE) # Reset to FALSE on error
            NULL
          }
        )
      })

      # Output the plot generation status as reactive
      output$plotGenerated <- reactive({
        plotGenerated()
      })
      outputOptions(output, "plotGenerated", suspendWhenHidden = FALSE) # Ensure reactive value is available in UI


      # Calculate alignment metrics after plot is generated
      observeEvent(plotGenerated(), {
        if (plotGenerated()) {
          reactiveData$alignment_summary <- calculateAlignmentMetrics(data = reactiveData, alignment_list_filepath = alignment_list_filepath)
        }
      })

      # Render alignment summary UI
      output$alignmentSummaryUI <- renderUI({
        if (plotGenerated() && !is.null(reactiveData$alignment_summary)) {
          tagList(
            h4("Metrics Summary"),
            textOutput("percentageAlignedText"),
            textOutput("adjustedAlignedText")
          )
        }
      })

      # Render name mapping table for G
      output$nameMappingTableG <- renderTable({
        if (!is.null(reactiveData$name_mapping_G)) {
          reactiveData$name_mapping_G
        } else {
          NULL
        }
      })

      # Render name mapping table for A
      output$nameMappingTableA <- renderTable({
        if (!is.null(reactiveData$name_mapping_A)) {
          reactiveData$name_mapping_A
        } else {
          NULL
        }
      })

      output$nameMappingUI <- renderUI({
        if ((!is.null(reactiveData$name_mapping_G) && any(reactiveData$name_mapping_G$Is_Truncated)) ||
          (!is.null(reactiveData$name_mapping_A) && any(reactiveData$name_mapping_A$Is_Truncated))) {
          fluidRow(
            column(
              6,
              tagList(
                h4("Name Mapping Table for G"),
                if (!is.null(reactiveData$name_mapping_G) && any(reactiveData$name_mapping_G$Is_Truncated)) {
                  tableOutput("nameMappingTableG")
                } else {
                  p("No names were truncated in G.")
                }
              )
            ),
            column(
              6,
              tagList(
                h4("Name Mapping Table for A"),
                if (!is.null(reactiveData$name_mapping_A) && any(reactiveData$name_mapping_A$Is_Truncated)) {
                  tableOutput("nameMappingTableA")
                } else {
                  p("No names were truncated in A.")
                }
              )
            )
          )
        } else {
          p("No names were truncated in either G or A.")
        }
      })
    }
  })

  # Alignment metrics function
  calculateAlignmentMetrics <- function(data, alignment_list_filepath) {
    if (is.null(data$adj_G) || is.null(data$adj_A) || is.null(data$alignment_GA)) {
      return(NULL)
    }
    aligned_edges <- sum(data$alignment_GA > 0)
    print(aligned_edges)
    min_nodes <- min(nrow(data$adj_G), nrow(data$adj_A))
    percentage_aligned <- (aligned_edges / min_nodes) * 100

    # alignment_dir <- sprintf("%s-%s", tools::file_path_sans_ext(basename(G)), tools::file_path_sans_ext(basename(H)))

    # alignment_list_filepath <- file.path(output_dir, alignment_dir, "alignment_list.csv")

    header_line <- readLines(alignment_list_filepath, n = 1)
    total_cost <- as.numeric(sub("X", "", strsplit(header_line, ",")[[1]][1]))
    print(total_cost)
    adjusted_aligned <- ((aligned_edges - total_cost) / aligned_edges) * 100
    list(
      percentage_aligned = percentage_aligned,
      adjusted_aligned = adjusted_aligned
    )
  }

  # Output alignment summary metrics
  output$percentageAlignedText <- renderText({
    metrics <- reactiveData$alignment_summary
    paste("Percentage of Aligned Edge Pairs:", round(metrics$percentage_aligned, 2), "%")
  })

  output$adjustedAlignedText <- renderText({
    metrics <- reactiveData$alignment_summary
    paste("Adjusted Number of Aligned Edge Pairs:", round(metrics$adjusted_aligned, 2))
  })

  output$downloadPlot <- downloadHandler(
    filename = function() {
      paste0("network_plot_", Sys.Date(), ".", tolower(input$downloadFormat)) # Use the selected format
    },
    content = function(file) {
      # Check if the plot exists
      if (is.null(reactiveData$plot)) {
        showNotification("No plot to download.", type = "error")
        return()
      }

      # Save the Plotly plot as an HTML file
      temp_html <- tempfile(fileext = ".html")
      saveWidget(as_widget(reactiveData$plot), temp_html, selfcontained = FALSE)

      # Define high-resolution settings
      resolution <- 300 # DPI (dots per inch)
      vwidth <- 2400 # Width in pixels
      vheight <- 2400 # Height in pixels
      zoom <- resolution / 96 # Standard DPI is 96; scale for high resolution

      if (input$downloadFormat == "PNG") {
        # Convert HTML to high-resolution PNG
        temp_png <- tempfile(fileext = ".png")
        webshot(temp_html, file = temp_png, vwidth = vwidth, vheight = vheight, zoom = zoom)
        file.copy(temp_png, file)
      } else if (input$downloadFormat == "JPEG") {
        # Convert HTML to high-resolution JPEG
        temp_png <- tempfile(fileext = ".png")
        webshot(temp_html, file = temp_png, vwidth = vwidth, vheight = vheight, zoom = zoom)
        img <- readPNG(temp_png)
        writeJPEG(img, target = file, quality = 1) # Set quality to maximum
      } else {
        # Unsupported format
        showNotification("Unsupported file format.", type = "error")
      }
    }
  )

  ######## RESULTS TAB ########

  resultDirectory <- "./alignments"

  # Dynamically populate folder choices
  output$select.folder <- renderUI({
    selectInput(
      inputId = "folder.name",
      label = "Result Folder",
      choices = list.dirs(
        path = resultDirectory,
        full.names = FALSE,
        recursive = FALSE
      )
    )
  })

  # Dynamically populate file choices when a folder is selected
  observeEvent(input$folder.name, {
    files <- list.files(path = file.path(resultDirectory, input$folder.name))
    updatePickerInput(session, "file.name", choices = files)

    # Extract the network names (for G and H) from the uploaded files (assuming they are present)
    g_gdvs_file <- grep("_gdvs.csv", files, value = TRUE, fixed = TRUE)

    if (length(g_gdvs_file) >= 2) {
      # Assuming the first is G and the second is H
      g_file <- g_gdvs_file[1]
      h_file <- g_gdvs_file[2]

      # Dynamically update G and H Graphlet files
      output$metadata_g_file <- renderUI({
        p(paste(g_file, ": Graphlet Degree Vectors for network G."))
      })

      output$metadata_h_file <- renderUI({
        p(paste(h_file, ": Graphlet Degree Vectors for network H."))
      })

      # Dynamically update g.csv and h.csv files
      g_csv <- sub("_gdvs.csv", ".csv", g_file)
      h_csv <- sub("_gdvs.csv", ".csv", h_file)

      output$metadata_g_csv <- renderUI({
        p(paste(g_csv, ": Processed data for network G."))
      })

      output$metadata_h_csv <- renderUI({
        p(paste(h_csv, ": Processed data for network H."))
      })
    }
  })

  # Display alignment list when the alignment_list.csv is selected
  output$alignment.list <- renderTable({
    if (is.null(input$folder.name)) {
      return(NULL) # No folder selected, don't display anything
    }

    # Define the file path for the alignment list
    file_path <- file.path(resultDirectory, input$folder.name, "alignment_list.csv")

    # Check if the file exists in the folder
    if (file.exists(file_path)) {
      # Read the alignment_list.csv file and display it as a table
      alignment_data <- read.csv(file_path)

      # Filter the data based on the threshold input (assuming 3rd column is the threshold)
      threshold <- input$threshold
      filtered_data <- alignment_data[alignment_data[, 3] >= threshold, ]

      # Rename the columns to "Network" and "Alignment Score"
      colnames(filtered_data)[1:3] <- c("NetworkG", "NetworkH", "Alignment Score")

      # Return the filtered data
      return(filtered_data)
    } else {
      return(NULL) # File doesn't exist, return NULL to show nothing
    }
  })

  # Download the selected files as a zip archive
  output$download.folder <- downloadHandler(
    filename = function() {
      paste(input$folder.name, ".zip", sep = "")
    },
    content = function(file) {
      # Zip selected files from the selected folder
      selected_files <- input$file.name
      file_paths <- file.path(resultDirectory, input$folder.name, selected_files)

      zip::zipr(zipfile = file, files = file_paths)
    }
  )

  ######## VISUALIZE TAB ########

  # Track plot generation status
  plotGenerated <- reactiveVal(FALSE)

  # Define reactive values for data
  reactiveData <- reactiveValues(adj_G = NULL, adj_A = NULL, alignment_GA = NULL, plot = NULL, name_mapping = NULL, alignment_list = NULL)

  alignment_list_filepath <- reactive({
    req(input$vis_GFile, input$vis_HFile) # Ensure files are uploaded

    # Construct the alignment directory using file names
    alignment_dir <- sprintf(
      "%s-%s",
      tools::file_path_sans_ext(basename(input$vis_GFile$name)),
      tools::file_path_sans_ext(basename(input$vis_HFile$name))
    )
    file.path("alignments", alignment_dir, "alignment_list.csv") # Adjust directory if needed
  })

  # print(alignment_list_filepath)
  # Handle the execution on clicking the submit button
  observeEvent(input$vis_submitInputs, {
    # Validation checks for file uploads
    if (is.null(input$vis_GFile)) {
      showNotification("Error: Please upload a file for Network G.", type = "error", duration = 5)
      return() # Stop execution if validation fails
    }

    if (is.null(input$vis_HFile)) {
      showNotification("Error: Please upload a file for Network H.", type = "error", duration = 5)
      return() # Stop execution if validation fails
    }

    if (is.null(input$vis_AFile)) {
      showNotification("Error: Please upload an alignment matrix file.", type = "error", duration = 5)
      return() # Stop execution if validation fails
    }

    # Load the G and H adjacency matrices and alignment matrix
    reactiveData$adj_G <- as.matrix(read.csv(input$vis_GFile$datapath, row.names = 1))
    reactiveData$adj_A <- as.matrix(read.csv(input$vis_HFile$datapath, row.names = 1))
    reactiveData$alignment_GA <- as.matrix(read.csv(input$vis_AFile$datapath, row.names = 1))
    # print(input$vis_AFile)
    alignment_list <- as.data.frame(read.csv(alignment_list_filepath(), header = TRUE))

    if (file.exists(alignment_list_filepath())) {
      reactiveData$alignment_list <- as.matrix(read.csv(alignment_list_filepath(), header = TRUE))
      # print(reactiveData$alignment_list)

      # Extract the total cost from the header of alignment_list.csv
      # header_line <- readLines(alignment_list_filepath(), n = 1)
      # total_cost <- as.numeric(sub("X", "", strsplit(header_line, ",")[[1]][1]))
      total_cost <- as.numeric(sub("X", "", colnames(alignment_list)[1]))
      print(total_cost)

      if (is.null(reactiveData$adj_G) || is.null(reactiveData$adj_A) || is.null(reactiveData$alignment_GA)) {
        return(NULL)
      }
      aligned_edges <- sum(reactiveData$alignment_GA > 0)
      print(aligned_edges)
      min_nodes <- min(nrow(reactiveData$adj_G), nrow(reactiveData$adj_A))
      percentage_aligned <- (aligned_edges / min_nodes) * 100

      # alignment_dir <- sprintf("%s-%s", tools::file_path_sans_ext(basename(G)), tools::file_path_sans_ext(basename(H)))

      # alignment_list_filepath <- file.path(output_dir, alignment_dir, "alignment_list.csv")

      # header_line <- readLines(alignment_list_filepath, n = 1)
      # total_cost <- as.numeric(sub("X", "", strsplit(header_line, ",")[[1]][1]))
      # print(total_cost)
      adjusted_aligned <- ((aligned_edges - total_cost) / aligned_edges) * 100
      percentage_aligned <- percentage_aligned
      adjusted_aligned <- adjusted_aligned

      # Calculate metrics
      # metrics <- calculateAlignmentMetrics(data=reactiveData, alignment_list_filepath = alignment_list_filepath)
      # reactiveData$alignment_summary <- metrics

      # Display the metrics and plot the network (assuming the rest of the code for visualization exists)
      output$alignmentSummaryUI_ <- renderUI({
        tagList(
          h4("Metrics Summary"),
          p(paste("Percentage of Aligned Edge Pairs:", round(percentage_aligned, 2), "%")),
          p(paste("Adjusted Number of Aligned Edge Pairs:", round(adjusted_aligned, 2)))
        )
      })
    } else {
      showNotification("Error: alignment_list.csv not found.", type = "error", duration = 5)
    }

    # Render the Plotly plot and store the plot and name mapping
    output$vis_networkPlot <- renderPlotly({
      tryCatch(
        {
          # Generate the plot and name mapping
          result <- plot_aligned_networks(
            adj_G = reactiveData$adj_G,
            adj_A = reactiveData$adj_A,
            alignment_GA = reactiveData$alignment_GA,
            th_align = input$vis_th_align,
            zero_degree = input$vis_zero_degree,
            # vertex_label_value = input$vis_vertex_label_value,
            size_aligned = input$vis_size_aligned,
            node_G_color = input$vis_node_G_color,
            node_H_color = input$vis_node_H_color,
            edge_G_color = input$vis_edge_G_color,
            edge_H_color = input$vis_edge_H_color,
            line_GH_color = input$vis_line_GH_color,
            aligned_G_color = input$vis_aligned_G_color,
            aligned_H_color = input$vis_aligned_H_color
          )

          # Store the plot and name mapping
          reactiveData$plot <- result$plot
          reactiveData$name_mapping_G <- result$name_mapping_G
          reactiveData$name_mapping_A <- result$name_mapping_A
          plotGenerated(TRUE) # Indicate plot is generated

          # Show notification
          showNotification("Plot generated successfully.", type = "message")

          result$plot # Return the Plotly plot
        },
        error = function(e) {
          print(paste("Error in renderPlotly:", e$message))
          plotGenerated(FALSE) # Reset on error
          NULL
        }
      )
    })
  })

  # Output plot generation status for download button
  output$vis_plotGenerated <- reactive({
    plotGenerated()
  })
  outputOptions(output, "vis_plotGenerated", suspendWhenHidden = FALSE)

  # Render the name mapping tables or messages only after "Run" is clicked
  output$nameMappingUI_ <- renderUI({
    if (plotGenerated()) {
      if ((!is.null(reactiveData$name_mapping_G) && any(reactiveData$name_mapping_G$Is_Truncated)) ||
        (!is.null(reactiveData$name_mapping_A) && any(reactiveData$name_mapping_A$Is_Truncated))) {
        fluidRow(
          column(
            6,
            tagList(
              h4("Name Mapping Table for G"),
              if (!is.null(reactiveData$name_mapping_G) && any(reactiveData$name_mapping_G$Is_Truncated)) {
                tableOutput("nameMappingTableG")
              } else {
                p("No names were truncated in G.")
              }
            )
          ),
          column(
            6,
            tagList(
              h4("Name Mapping Table for A"),
              if (!is.null(reactiveData$name_mapping_A) && any(reactiveData$name_mapping_A$Is_Truncated)) {
                tableOutput("nameMappingTableA")
              } else {
                p("No names were truncated in A.")
              }
            )
          )
        )
      } else {
        p("No names were truncated in either G or A.")
      }
    } else {
      NULL # Hide initially until "Run" is clicked
    }
  })

  # Render the name mapping table for G
  output$nameMappingTableG <- renderTable({
    reactiveData$name_mapping_G
  })

  # Render the name mapping table for A
  output$nameMappingTableA <- renderTable({
    reactiveData$name_mapping_A
  })

  # Download plot as PNG or JPEG
  output$vis_downloadPlot <- downloadHandler(
    filename = function() {
      format <- input$vis_downloadFormat
      paste0("network_plot_", Sys.Date(), ".", tolower(format))
    },
    content = function(file) {
      # Generate the plot using the plot_aligned_networks function
      p <- plot_aligned_networks(
        adj_G = reactiveData$adj_G,
        adj_A = reactiveData$adj_A,
        alignment_GA = reactiveData$alignment_GA,
        th_align = input$vis_th_align,
        zero_degree = input$vis_zero_degree,
        # vertex_label_value = input$vis_vertex_label_value,
        size_aligned = input$vis_size_aligned,
        node_G_color = input$vis_node_G_color,
        node_H_color = input$vis_node_H_color,
        edge_G_color = input$vis_edge_G_color,
        edge_H_color = input$vis_edge_H_color,
        line_GH_color = input$vis_line_GH_color,
        aligned_G_color = input$vis_aligned_G_color,
        aligned_H_color = input$vis_aligned_H_color
      )$plot

      # Save as HTML temporarily
      temp_html <- tempfile(fileext = ".html")
      saveWidget(as_widget(p), temp_html, selfcontained = FALSE)

      # Convert HTML to high-resolution PNG or JPEG
      temp_png <- tempfile(fileext = ".png")
      webshot(temp_html, file = temp_png, vwidth = 2400, vheight = 2400, zoom = 3)

      if (input$vis_downloadFormat == "JPEG") {
        img <- readPNG(temp_png)
        writeJPEG(img, target = file, quality = 1)
      } else {
        file.copy(temp_png, file)
      }
    }
  )
}
