options(shiny.maxRequestSize = 10*2^20) # raise limit from 5MB default to 10MB
library(igraph)

# Define the plot_aligned_networks function outside the server function
plot_aligned_networks <- function(adj_G, adj_A, alignment_GA, th_align, zero_degree, vertex_label_value, size_aligned,
                                  node_G_color, node_H_color, edge_G_color, edge_H_color, line_GH_color, aligned_G_color, aligned_H_color) {
  
  # Create graph objects from adjacency matrices for G and A
  graph_G <- graph_from_adjacency_matrix(adj_G, mode="undirected")
  V(graph_G)$name <- rownames(adj_G)
  
  graph_A <- graph_from_adjacency_matrix(adj_A, mode="undirected")
  V(graph_A)$name <- rownames(adj_A)
  
  # Identify aligned nodes based on alignment threshold
  alignment_indices <- which(alignment_GA >= th_align, arr.ind=TRUE)
  aligned_nodes_G <- V(graph_G)$name[alignment_indices[, 1]]
  aligned_nodes_A <- V(graph_A)$name[alignment_indices[, 2]]
  
  # Optionally remove nodes with degree 0, except aligned nodes
  zero_deg_nodes_G <- V(graph_G)[degree(graph_G) < zero_degree & !(V(graph_G)$name %in% aligned_nodes_G)]
  zero_deg_nodes_A <- V(graph_A)[degree(graph_A) < zero_degree & !(V(graph_A)$name %in% aligned_nodes_A)]
  graph_G <- delete.vertices(graph_G, zero_deg_nodes_G)
  graph_A <- delete.vertices(graph_A, zero_deg_nodes_A)
  
  # Re-calculate aligned nodes after node removal
  aligned_indices_G <- match(aligned_nodes_G, V(graph_G)$name)
  aligned_indices_A <- match(aligned_nodes_A, V(graph_A)$name)
  
  # Filter out NA values from aligned indices
  valid_indices <- which(!is.na(aligned_indices_G) & !is.na(aligned_indices_A))
  aligned_indices_G <- aligned_indices_G[valid_indices]
  aligned_indices_A <- aligned_indices_A[valid_indices]
  
  # Create a combined graph for visualization (disjoint union of G and A)
  combined_graph <- graph.disjoint.union(graph_G, graph_A)
  
  # Define circular layout for G and A separately
  layout_G <- layout_in_circle(graph_G)
  layout_A <- layout_in_circle(graph_A)
  
  # Adjust the layout so that aligned nodes are directly opposite each other
  adjust_opposite_positions <- function(layout_G, layout_A, indices_G, indices_A) {
    num_nodes <- length(indices_G)
    angle_step <- pi / (num_nodes + 1)
    start_angle <- pi / 2
    
    for (i in seq_along(indices_G)) {
      angle <- start_angle - (i * angle_step)
      layout_G[indices_G[i], ] <- c(cos(angle), sin(angle))
      layout_A[indices_A[i], ] <- c(-cos(angle), sin(angle))
    }
    return(list(layout_G, layout_A))
  }
  
  # Adjust positions for aligned nodes
  layouts <- adjust_opposite_positions(layout_G, layout_A, aligned_indices_G, aligned_indices_A)
  layout_G <- layouts[[1]]
  layout_A <- layouts[[2]]
  
  # Reduce the separation distance between G and A networks
  layout_G <- layout_G - cbind(rep(3, nrow(layout_G)), rep(0, nrow(layout_G)))  # Increase the gap between networks
  layout_A <- layout_A + cbind(rep(3, nrow(layout_A)), rep(0, nrow(layout_A)))
  
  
  # Combine the layouts of G and A into one layout
  layout_combined <- rbind(layout_G, layout_A)
  
  # Add edges between aligned nodes from G to A in the combined graph
  for (i in seq_along(aligned_indices_G)) {
    combined_graph <- add_edges(combined_graph, c(aligned_indices_G[i], aligned_indices_A[i] + vcount(graph_G)))
  }
  
  # Define colors for vertices and edges based on user inputs
  vertex_colors <- c(rep(node_G_color, vcount(graph_G)), rep(node_H_color, vcount(graph_A)))
  vertex_colors[aligned_indices_G] <- aligned_G_color  # Use the user-defined color for aligned nodes in G
  vertex_colors[aligned_indices_A + vcount(graph_G)] <- aligned_H_color 
      
    edge_colors <- c(rep(edge_G_color, ecount(graph_G)), rep(edge_H_color, ecount(graph_A)), rep(line_GH_color, length(aligned_indices_G)))
    
    # Define sizes for vertices and labels based on user inputs
    vertex_sizes <- rep(1, vcount(combined_graph))
    vertex_sizes[c(aligned_indices_G, aligned_indices_A + vcount(graph_G))] <- size_aligned
    
    vertex_label_sizes <- rep(vertex_label_value, vcount(combined_graph))
    vertex_label_sizes[c(aligned_indices_G, aligned_indices_A + vcount(graph_G))] <- vertex_label_value
    
    # Plot the combined graph with the specified layouts and colors
    plot(combined_graph, layout=layout_combined,
         vertex.label=V(combined_graph)$name,  # Add vertex labels
         vertex.size=vertex_sizes,  # Adjust vertex size for better visualization
         vertex.label.cex=vertex_label_sizes,  # Adjust label size for readability
         vertex.color=vertex_colors,  # Set vertex colors
         edge.color=edge_colors,  # Set edge colors
         edge.width=c(rep(1, ecount(graph_G) + ecount(graph_A)), rep(2, length(aligned_indices_G))),
         asp=0)  # Keep aspect ratio constant
}

function(input, output, session) {
  ######## RUN TAB ########
  plotGenerated <- reactiveVal(FALSE)  
  output_dir <- "alignments/"
  
  # Reactive values to store matrices for use in both plot and download
  reactiveData <- reactiveValues(
    adj_G = NULL,
    adj_A = NULL,
    alignment_GA = NULL
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
      return()  # Stop execution if validation fails
    }
    
    if (is.null(input$align_HFile)) {
      showNotification("Error: Please upload a file for Network H.", type = "error", duration = 5)
      return()  # Stop execution if validation fails
    }
    
    # Get file paths and user inputs
    G <- input$align_GFile$datapath
    H <- input$align_HFile$datapath
    B <- input$align_BFile$datapath  # Optional
    a <- input$alphaIn
    b <- input$betaIn
    
    # Build the arguments for the system call
    arg_G <- paste0(" ", G)
    arg_H <- paste0(" ", H)
    arg_B <- ifelse(is.null(B), "", paste0(" -B=", B))  # B is optional
    arg_a <- ifelse(is.null(a) || is.na(a), "", paste0(" -a=", a))
    arg_b <- ifelse(is.null(b) || is.na(b), "", paste0(" -b=", b))
    arg_s <- ifelse(input$is_bio_matrix, " -s", "")  # Add '-s' flag if 'is_bio_matrix' is TRUE
    arg_p <- " -p"  # Assuming -p is always required
    
    args <- paste0("./minaa.exe", arg_G, arg_H, arg_B, arg_a, arg_b, arg_s, arg_p)
    result <- system(args, intern = TRUE)  # Capture output for debugging
    
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
      
      # Load the alignment matrix from the output file generated by minaa.exe
      if (!file.exists(alignment_matrix_filepath)) {
        showNotification("Error: alignment_matrix.csv not found.", type = "error")
        return(NULL)
      }
      
      reactiveData$alignment_GA <- as.matrix(read.csv(alignment_matrix_filepath, row.names = 1))
      
      # Get user-defined parameters for the plot
      th_align <- input$th_align
      zero_degree <- input$zero_degree
      vertex_label_value <- input$vertex_label_value
      size_aligned <- input$size_aligned
      node_G_color <- input$node_G_color
      node_H_color <- input$node_H_color
      edge_G_color <- input$edge_G_color
      edge_H_color <- input$edge_H_color
      line_GH_color <- input$line_GH_color
      aligned_G_color <- input$aligned_G_color  # Get color for aligned nodes in G
      aligned_H_color <- input$aligned_H_color  # Get color for aligned nodes in H
      
      # Render the plot in a separate output area (networkPlot)
      output$networkPlot <- renderPlot({
        plot_aligned_networks(
          adj_G = reactiveData$adj_G,
          adj_A = reactiveData$adj_A,
          alignment_GA = reactiveData$alignment_GA,
          th_align = th_align,
          zero_degree = zero_degree,
          vertex_label_value = vertex_label_value,
          size_aligned = size_aligned,
          node_G_color = node_G_color,
          node_H_color = node_H_color,
          edge_G_color = edge_G_color,
          edge_H_color = edge_H_color,
          line_GH_color = line_GH_color,
          aligned_G_color = aligned_G_color,  # Pass aligned G color
          aligned_H_color = aligned_H_color   # Pass aligned H color
        )
        plotGenerated(TRUE)
      }, height = 1000, width = 1000)
      
      output$plotGenerated <- reactive({
        plotGenerated()
      })
      outputOptions(output, "plotGenerated", suspendWhenHidden = FALSE)  # Required for conditional rendering
      
      # Show notification when the plot is generated
      showNotification("Plot generated successfully.", type = "message")
    }
  })
  
  # Download plot as PNG or JPEG
  output$downloadPlot <- downloadHandler(
    filename = function() {
      format <- input$downloadFormat
      paste0("network_plot_", Sys.Date(), ".", tolower(format))
    },
    content = function(file) {
      width <- 12  # Width in inches
      height <- 12  # Height in inches
      dpi <- 300  # Resolution in DPI
      
      # Use png() or jpeg() depending on selected format
      if (input$downloadFormat == "PNG") {
        png(file, width = width, height = height, units = "in", res = dpi)
      } else {
        jpeg(file, width = width, height = height, units = "in", res = dpi)
      }
      # Recreate the plot here
      plot_aligned_networks(
        adj_G = reactiveData$adj_G,
        adj_A = reactiveData$adj_A,
        alignment_GA = reactiveData$alignment_GA,
        th_align = input$th_align,
        zero_degree = input$zero_degree,
        vertex_label_value = input$vertex_label_value,
        size_aligned = input$size_aligned,
        node_G_color = input$node_G_color,
        node_H_color = input$node_H_color,
        edge_G_color = input$edge_G_color,
        edge_H_color = input$edge_H_color,
        line_GH_color = input$line_GH_color,
        aligned_G_color = input$aligned_G_color,
        aligned_H_color = input$aligned_H_color
      )
      dev.off()
    }
  )
  
  
  ######## RESULTS TAB ########
  
  resultDirectory <- './alignments'
  
  # Handle result selection
  output$select.folder <-
    renderUI(expr = selectInput(inputId = 'folder.name',
                                label = 'Result Folder',
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
  
  # Upload Dataset // Probably cancel this
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
  
  ######## VISUALIZE TAB ########
  visualizeDirectory <- './alignments'
  
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
