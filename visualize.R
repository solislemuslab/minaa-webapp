library(igraph)
library(readr)
library(ggplot2)
library(ggraph)

generate_network_plot <- function(
    g_path,
    h_path,
    a_path) {
  # Function to read adjacency matrix from CSV file
  read_adjacency_matrix <- function(file_path) {
    adjacency_matrix <- read.csv(file_path, header = TRUE, row.names = 1)
    adjacency_matrix <- as.matrix(adjacency_matrix)
    # print(adjacency_matrix) # DEBUG
    # print(rownames(adjacency_matrix)) # DEBUG
    # print(colnames(adjacency_matrix)) # DEBUG
    return(adjacency_matrix)
  }

  # Read the adjacency matrices for G, H, and the alignment A
  g_matrix <- read_adjacency_matrix(g_path)
  h_matrix <- read_adjacency_matrix(h_path)
  # a_matrix <- read_adjacency_matrix(a_path)

  # Create the graph for G
  g_graph <- graph_from_adjacency_matrix(
    g_matrix,
    mode = "undirected"
  )
  V(g_graph)$color <- "blue"
  E(g_graph)$color <- "blue"

  # Create the graph for H
  h_graph <- graph_from_adjacency_matrix(
    h_matrix,
    mode = "undirected"
  )
  V(h_graph)$color <- "red"
  E(h_graph)$color <- "red"

  # # Create the graph for the alignment A
  # a_graph <- graph_from_adjacency_matrix(
  #   a_matrix,
  #   mode = "undirected"
  # )
  # E(a_graph)$color <- "purple"

  # # Create a new graph and add the vertices and edges
  # # from each of the three graphs
  # combined_graph <- graph(NULL)
  # combined_graph <- add_vertices(
  #   combined_graph, vcount(g_graph) + vcount(h_graph),
  #   attr = list(name = c(
  #     V(g_graph)$name,
  #     V(h_graph)$name
  #   ))
  # )
  # combined_graph <- add_edges(
  #   combined_graph, get.edgelist(g_graph)
  # )
  # combined_graph <- add_edges(
  #   combined_graph, get.edgelist(h_graph)
  # )
  # combined_graph <- add_edges(
  #   combined_graph, get.edgelist(a_graph)
  # )

  # Begin plotting
  # Extract node and edge data from the graph
  node_data <- data.frame(
    name = c(
      V(g_graph)$name,
      V(h_graph)$name
    ),
    color = c(
      rep("blue", vcount(g_graph)),
      rep("red", vcount(h_graph))
    )
  )
  edge_data <- data.frame(
    from = c(
      get.edgelist(g_graph)[, 1],
      get.edgelist(h_graph)[, 1]
      # get.edgelist(a_graph)[, 1]
    ),
    to = c(
      get.edgelist(g_graph)[, 2],
      get.edgelist(h_graph)[, 2]
      # get.edgelist(a_graph)[, 2]
    ),
    color = c(
      rep("blue", ecount(g_graph)),
      rep("red", ecount(h_graph))
      # rep("purple", ecount(a_graph))
    )
  )

  # print(get.edgelist(a_graph)[, 1])
  # print(get.edgelist(a_graph)[, 2])

  # Draw the combined network using ggplot and ggraph
  combined_network <- graph_from_data_frame(
    edge_data,
    directed = FALSE,
    vertices = node_data
  )
  combined_network_plot <- ggraph(combined_network, layout = "kk") +
    geom_edge_link(
      aes(
        edge_alpha = 0.5,
        edge_width = 0.5,
        color = color
      )
    ) +
    geom_node_point(
      aes(
        color = color
      ),
      size = 2
    ) +
    theme_void() +
    theme(
      legend.position = "none"
    )

  # Save the plot to a file
  ggsave("./alignments/G-10-0.1-1-G-10-0.1-2/alignment.png")
}

generate_network_plot(
  "./alignments/G-10-0.1-1-G-10-0.1-2/G-10-0.1-1.csv",
  "./alignments/G-10-0.1-1-G-10-0.1-2/G-10-0.1-2.csv",
  "./alignments/G-10-0.1-1-G-10-0.1-2/alignment_matrix.csv"
)








# library(igraph)
# library(readr)
# library(ggplot2)

# generate_network_plot <- function(adjacency_matrix_G_path, adjacency_matrix_H_path, alignment_matrix_path) {
#   # Function to read adjacency matrix from CSV file
#   # read_adjacency_matrix <- function(file_path) {
#   #   adjacency_matrix <- read.csv(file_path, header = FALSE)
#   #   adjacency_matrix <- as.matrix(adjacency_matrix)
#   #   rownames(adjacency_matrix) <- 1:nrow(adjacency_matrix)
#   #   colnames(adjacency_matrix) <- 1:ncol(adjacency_matrix)
#   #   print(adjacency_matrix)
#   #   print(rownames(adjacency_matrix))
#   #   print(colnames(adjacency_matrix))
#   #   return(adjacency_matrix)
#   # }

#   read_adjacency_matrix <- function(file_path) {
#     adjacency_matrix <- read.csv(file_path, header = TRUE, row.names = 1)
#     adjacency_matrix <- as.matrix(adjacency_matrix)
#       print(adjacency_matrix)
#       print(rownames(adjacency_matrix))
#       print(colnames(adjacency_matrix))
#     return(adjacency_matrix)
#   }

#   # Read the adjacency matrices for G, H, and the alignment A
#   adjacency_matrix_G <- read_adjacency_matrix(adjacency_matrix_G_path)
#   adjacency_matrix_H <- read_adjacency_matrix(adjacency_matrix_H_path)
#   alignment_matrix <- read_adjacency_matrix(alignment_matrix_path)

#   # Create the graph for G
#   graph_G <- graph_from_adjacency_matrix(adjacency_matrix_G, mode = "undirected")
#   V(graph_G)$color <- "blue"

#   # Create the graph for H
#   graph_H <- graph_from_adjacency_matrix(adjacency_matrix_H, mode = "undirected")
#   V(graph_H)$color <- "red"

#   # Create the graph for the alignment A
#   graph_A <- graph_from_adjacency_matrix(alignment_matrix, mode = "directed")
#   E(graph_A)$color <- "purple"

#   # Create a new graph and add the vertices and edges from each of the three graphs
#   graph_combined <- graph()
#   graph_combined <- add_vertices(graph_combined, vcount(graph_G) + vcount(graph_H) + vcount(graph_A))
#   graph_combined <- add_edges(graph_combined, get.edgelist(graph_G))
#   graph_combined <- add_edges(graph_combined, get.edgelist(graph_H) + vcount(graph_G))
#   graph_combined <- add_edges(graph_combined, get.edgelist(graph_A) + c(vcount(graph_G), vcount(graph_G) + vcount(graph_H)))

#   # Plot the combined graph
#   plot(graph_combined, vertex.label = NA, vertex.size = 10, edge.arrow.size = 0.5,
#        vertex.color = c(rep("blue", vcount(graph_G)), rep("red", vcount(graph_H))),
#        edge.color = c(rep("blue", ecount(graph_G)), rep("red", ecount(graph_H)), rep("purple", ecount(graph_A))))
# }

# generate_network_plot(
#   "./alignments/G-10-0.1-1-G-10-0.1-2/G-10-0.1-1.csv",
#   "./alignments/G-10-0.1-1-G-10-0.1-2/G-10-0.1-2.csv",
#   "./alignments/G-10-0.1-1-G-10-0.1-2/alignment_matrix.csv")

# library(igraph)
# library(readr)
# library(ggplot2)
#
# generate_network_plot <- function(adjacency_matrix_G_path, adjacency_matrix_H_path, alignment_matrix_path) {
#
#   print("1") # DEBUG
#
#   # Function to read adjacency matrix from CSV file
#   read_adjacency_matrix <- function(file_path) {
#     adjacency_matrix <- read_csv(file_path)
#     print(adjacency_matrix)
#     adjacency_matrix <- as.matrix(adjacency_matrix)
#     rownames(adjacency_matrix) <- 1:nrow(adjacency_matrix)
#     colnames(adjacency_matrix) <- 1:ncol(adjacency_matrix)
#     return(adjacency_matrix)
#   }
#
#
#   # Read the adjacency matrices for G, H, and the alignment A
#   adjacency_matrix_G <- read_adjacency_matrix(adjacency_matrix_G_path)
#   print("2") # DEBUG
#   adjacency_matrix_H <- read_adjacency_matrix(adjacency_matrix_H_path)
#   print("3") # DEBUG
#   alignment_matrix <- read_adjacency_matrix(alignment_matrix_path)
#   print("4") # DEBUG
#
#   # Create an empty graph
#   graph <- graph()
#
#   # Add nodes from G (blue)
#   V(graph)$color <- ifelse(V(graph) %in% V(graph, name = rownames(adjacency_matrix_G)), "blue", V(graph)$color)
#   print("5") # DEBUG
#   # Add nodes from H (red)
#   V(graph)$color <- ifelse(V(graph) %in% V(graph, name = colnames(adjacency_matrix_H)), "red", V(graph)$color)
#   print("6") # DEBUG
#   # Add edges from G (blue)
#   graph <- add_edges(graph, as.matrix(adjacency_matrix_G))
#   print("7") # DEBUG
#   E(graph)$color <- ifelse(E(graph) %in% get.edgelist(graph, names = FALSE, edges = E(graph)), "blue", E(graph)$color)
#   print("8") # DEBUG
#   # Add edges from G to H (purple) based on alignment matrix
#   for (i in 1:nrow(alignment_matrix)) {
#     for (j in 1:ncol(alignment_matrix)) {
#       if (!is.na(alignment_matrix[i, j])) {
#         graph <- add_edges(graph, c(i, j + nrow(adjacency_matrix_G)))
#         E(graph)$color <- ifelse(E(graph) %in% get.edgelist(graph, names = FALSE, edges = E(graph)), "purple", E(graph)$color)
#       }
#     }
#   }
#
#   # Plot the graph
#   plot(graph, vertex.color = V(graph)$color, edge.color = E(graph)$color,
#        vertex.size = 20, edge.arrow.size = 0.5, layout = layout_with_fr)
#
#   # Save the plot as an image file
#   ggsave("network_plot.png")
# }
#
# generate_network_plot(
#   "./alignments/G-10-0.1-1-G-10-0.1-2/G-10-0.1-1.csv",
#   "./alignments/G-10-0.1-1-G-10-0.1-2/G-10-0.1-2.csv",
#   "./alignments/G-10-0.1-1-G-10-0.1-2/alignment_matrix.csv")
