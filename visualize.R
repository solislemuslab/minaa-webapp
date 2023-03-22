


# /**
#   * Map the labels of the will-be merged matrix to the indices of it.
# *
#   * @param alignment The alignment between G and H.
# * @param g_labels The labels of G.
# * @param h_labels The labels of H.
# * @param gamma Gamma.
# *
#   * @return The labels of the merged matrix.
# *
#   * @throws
# */
merge_labels <- function(alignment, g_labels, h_labels, gamma) {
  merged_labels <- vector(mode = "character", length = 0)
  aligned <- FALSE
  #For each gi in G, label index i in merged with gi, or gi + hj if gi is aligned with hj
  
  for (i in seq_along(alignment)) {
    aligned <- FALSE
    for (j in seq_along(alignment[[1]])) {
      if (alignment[i][j] > 0 && alignment[i][j] >= gamma) {
        merged_labels <- c(merged_labels, paste0(g_labels[i], h_labels[j]))
        aligned <- TRUE
        break
      }
    }
    if (!aligned) {
      merged_labels <- c(merged_labels, g_labels[i])
    }
  }
  #For each hj in H that isn't aligned with gi, label the next index with hj
  
  for (j in seq_along(alignment[[1]])) {
    aligned <- FALSE
    for (i in seq_along(alignment)) {
      if (alignment[i][j] > 0 && alignment[i][j] >= gamma) {
        aligned <- TRUE
        break
      }
    }
    if (!aligned) {
      merged_labels <- c(merged_labels, h_labels[j])
    }
  }
  
  return(merged_labels)
}

# /**
#   * Assigns the entry at index (label1, label2) the merged matrix the given value.
# *
#   * @param merged The merged matrix.
# * @param merged_labels The labels of the merged matrix.
# * @param label1 The first label.
# * @param label2 The second label.
# * @param value The value to assign.
# *
#   * @return The merged matrix with the new value.
# *
#   * @throws
# */
# Note that in R, the index of a matrix or a two-dimensional array starts
# from 1, not 0 as in C++. Also, instead of using a vector of vectors to
# represent a matrix, R uses a two-dimensional array or a matrix. The "match"
# function in R is used to find the index of an element in a vector. Finally,
# instead of throwing an exception as in C++, we use the "stop" function in R
# to terminate the function and throw an error message.
assign <- function(merged,
                   merged_labels,
                   label1,
                   label2,
                   value) {
  i <- match(label1, merged_labels)
  j <- match(label2, merged_labels)
  if (is.na(i) || is.na(j)) {
    stop("One or both of the labels not found in merged_labels")
  }
  merged[i, j] <- value
  merged[j, i] <- value
  return(merged)
}



# Define function 'merge' in R
merge <-
  function(g_graph,
           h_graph,
           alignment,
           g_labels,
           h_labels,
           merged_labels,
           gamma) {
    # merged_i,j = 0 if there is no edge between nodes i and j
    # merged_i,j = 1 if only G draws an edge between nodes i and j
    # merged_i,j = 2 if only H draws an edge between nodes i and j
    # merged_i,j = 3 if both G and H draw an edge between nodes i and j
    
    # Initialize merged with 0s
    merged <-
      matrix(0,
             nrow = length(merged_labels),
             ncol = length(merged_labels))
    
    # Iterate through all nodes gi in G, aligned and unaligned
    for (gi in seq_len(nrow(g_graph))) {
      hj <- 1
      while (hj <= ncol(alignment)) {
        if (alignment[gi, hj] > 0 &&
            alignment[gi, hj] >= gamma) {
          # gi and hj are aligned
          # Iterate through all nodes gk adjacent to gi
          for (gk in seq_len(ncol(g_graph))) {
            if (g_graph[gi, gk] > 0 &&
                gi != gk) {
              # gi and gk are adjacent, ignoring self-loops
              hl <- 1
              while (hl <= ncol(alignment)) {
                if (alignment[gk, hl] > 0 && alignment[gk, hl] >= gamma) {
                  break # this gk is aligned with only this hl
                }
                hl <- hl + 1
              }
              if (hl <= ncol(alignment)) {
                # gk and hl are aligned
                label1 <- paste0(g_labels[gi], h_labels[hj])
                label2 <- paste0(g_labels[gk], h_labels[hl])
                if (h_graph[hj, hl] > 0) {
                  # hj is adjacent to hl
                  merged <-
                    assign(merged, merged_labels, label1, label2, 3)
                } else {
                  # hj is not adjacent to hl
                  merged <-
                    assign(merged, merged_labels, label1, label2, 1)
                }
              } else {
                # gk is unaligned
                label1 <- paste0(g_labels[gi], h_labels[hj])
                label2 <- g_labels[gk]
                merged <-
                  assign(merged, merged_labels, label1, label2, 1)
              }
            }
          }
          # Iterate through all nodes hk adjacent to hj
          for (hk in seq_len(ncol(h_graph))) {
            # for (hk in seq_along(h_graph[[1]])) {
            if (h_graph[hj, hk] > 0 &&
                hj != hk) {
              # hj and hk are adjacent, ignoring self-loops
              gl <- 1
              while (gl <= nrow(alignment)) {
                if (alignment[gl, hk] > 0 && alignment[gl, hk] >= gamma) {
                  break # this gl is aligned with only this hk
                }
                gl <- gl + 1
              }
              if (gl <= nrow(alignment)) {
                # hk and gl are aligned
                label1 <- g_labels[gi] + h_labels[hj]
                label2 <- g_labels[gl] + h_labels[hk]
                if (g_graph[gi, gl] > 0) {
                  # gi is adjacent to gl
                  # merged = assign(merged, merged_labels, label1, label2, 3)
                  next # we already recorded this merge
                } else {
                  # gi is not adjacent to gl
                  merged <-
                    assign(merged, merged_labels, label1, label2, 2)
                }
              } else {
                # hk is unaligned
                label1 <- g_labels[gi] + h_labels[hj]
                label2 <- h_labels[hk]
                merged <-
                  assign(merged, merged_labels, label1, label2, 2)
              }
            }
            break # this gi is aligned with only this hj
          }
          
          if (hj == ncol(alignment)) {
            # gi was aligned to no hj
            # Iterate through all nodes gj adjacent to gi
            
            for (gj in seq_along(g_graph[1,])) {
              if (g_graph[gi, gj] > 0 &&
                  gi != gj) {
                # gi and gj are adjacent, ignoring self-loops
                hk <- 1
                while (hk <= ncol(alignment)) {
                  if (alignment[gj, hk] > 0 && alignment[gj, hk] >= gamma) {
                    break # this gj is aligned with only this hk
                  }
                  hk <- hk + 1
                }
                if (hk <= ncol(alignment)) {
                  # gj and hk are aligned
                  label1 <- g_labels[gi]
                  label2 <- g_labels[gj] + h_labels[hk]
                  merged <-
                    assign(merged, merged_labels, label1, label2, 1)
                } else {
                  # gj is unaligned
                  label1 <- g_labels[gi]
                  label2 <- g_labels[gj]
                  merged <-
                    assign(merged, merged_labels, label1, label2, 1)
                }
              }
            }
          }
          # Iterate through the nodes hi in H that are not aligned to any node in G
          
          for (hi in 1:length(h_graph)) {
            gj <- 1
            while (gj <= nrow(alignment)) {
              if (alignment[gj, hi] > 0 && alignment[gj, hi] >= gamma) {
                break # skip any aligned hi
              }
              gj <- gj + 1
            }
            if (gj > nrow(alignment)) {
              # Iterate through all nodes hk adjacent to hi
              for (hk in 1:ncol(h_graph)) {
                if (h_graph[hi, hk] > 0 && hi != hk) {
                  gl <- 1
                  while (gl <= nrow(alignment)) {
                    if (alignment[gl, hk] > 0 && alignment[gl, hk] >= gamma) {
                      break # this hk is aligned with only this gl
                    }
                    gl <- gl + 1
                  }
                  if (gl <= nrow(alignment)) {
                    label1 <- h_labels[hi]
                    label2 <- g_labels[gl] + h_labels[hk]
                    merged <-
                      assign(merged, merged_labels, label1, label2, 2)
                  } else {
                    label1 <- h_labels[hi]
                    label2 <- h_labels[hk]
                    merged <-
                      assign(merged, merged_labels, label1, label2, 2)
                  }
                }
              }
            }
          }
        }
      }
      return(merged)
    }
  }
