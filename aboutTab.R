AboutTab <- tabPanel(
  "About",
  fluidPage(
    tags$head(
      tags$style(HTML("
        .about-panel {
          background-color: #f9f9f9;
          border: 1px solid #ddd;
          padding: 20px;
          border-radius: 10px;
          margin: 20px auto;
        }
        h2, h3, h4 {
          color: #0056b3;
          margin-top: 20px;
          margin-bottom: 15px;
        }
        p, ul, li {
          margin-left: 15px;
          margin-right: 15px;
          line-height: 1.5;
        }
        a {
          color: #007bff;
          text-decoration: none;
        }
        a:hover {
          text-decoration: underline;
        }
        iframe {
          display: block;
          margin-top: 15px;
          margin-bottom: 15px;
          border: 1px solid #ddd;
          border-radius: 10px;
          box-shadow: 0 4px 8px rgba(0, 0, 0, 0.1);
        }
      "))
    ),
    div(class = "about-panel",
        h2("About MiNAA"),
        p("MiNAA aligns two networks based on their topologies and biologies."),
        
        h3("Introduction Video"),
        tags$iframe(
          src = "https://www.youtube-nocookie.com/embed/S9PaA49xyBU",  # No-cookie embed link
          width = "480",  # Smaller width
          height = "270",  # Maintain 16:9 aspect ratio
          frameborder = "0",
          allow = "accelerometer; autoplay; clipboard-write; encrypted-media; gyroscope; picture-in-picture",
          allowfullscreen = TRUE
        ),
        
        h3("Inputs"),
        h4("G, H: the pair of networks to align"),
        tags$ul(
          tags$li("The networks must be represented by adjacency matrices in CSV format, with labels in both the first column and row."),
          tags$li("The CSV delimiter must be one of {comma, semicolon, space, tab}, and will be detected automatically."),
          tags$li("Any nonzero entry is considered an edge."),
          tags$li("|G| should be lesser or equal to |H|")
        ),
        h4("B: a biological cost matrix"),
        tags$ul(
          tags$li("CSV adjacency matrix where the first column is the labels of G, and the first row is the labels of H."),
          tags$li("By default, MiNAA will run using only topological calculations.")
        ),
        h4("\U03B1: GDV-edge weight balancer"),
        tags$ul(
          tags$li("\U03B1 must be a real number in range [0, 1]."),
          tags$li("By default, \U03B1 = 1.")
        ),
        h4("\U03B2: topological-biological cost matrix balancer"),
        tags$ul(
          tags$li("\U03B2 must be a real number in range [0, 1]."),
          tags$li("By default, \U03B2 = 1.")
        ),
        
        h3("Outputs"),
        tags$ul(
          tags$li("X-Y-T/: (where \"X\", \"Y\" are the input networks, \"T\" is the date and time of execution) The folder containing the output files specified below."),
          tags$li("log.txt: Record of the important details from the alignment."),
          tags$li("X_gdvs.csv: (where \"X\" is the input network) The Graphlet Degree Vectors for network \"X\"."),
          tags$li("top_costs.csv: The topological cost matrix."),
          tags$li("bio_costs.csv: The biological cost matrix (as inputed). Not created unless biological input is given."),
          tags$li("overall_costs.csv: The combination of the topological and biological cost matrix. Not created unless biological input is given."),
          tags$li("alignment_list.csv: A complete list of all aligned nodes, with rows in the format `g_node,h_node,similarity`, descending according to similarity. The first row in this list is the total cost of the alignment, or the sum of (1 - similarity) for all aligned pairs."),
          tags$li("alignment_matrix.csv: A matrix form of the same alignment, where the first column and row are the labels from the two input networks, respectively.")
        ),
        
        h3("Examples"),
        p("`./minaa.exe network0.csv network1.csv -a=0.6`"),
        p("Here we align network0 with network1 using no biological data. `-a=0.6` sets alpha equal to 0.6, meaning 60% of the topological cost function comes from similarity calculated by GDVs, and 40% from simpler node degree data."),
        p("`./minaa.exe network0.csv network1.csv bio_costs.csv -b=0.85`"),
        p("Here we align network0 with network1 using topological information and the given biological cost matrix, bio_costs. Since alpha and gamma were unspecified, they default to 0.5 and 1 respectively. Since beta was set to 0.85, 85% of the cost weight is from the topological cost matrix, and 15% is from the given biological cost matrix."),
        
        h2("The Manuscript"),
        p(
          "For a more detailed description of the MiNAA algorithm, a",
          a(href = "https://arxiv.org/abs/2212.05880", "manuscript"),
          "is currently available on arXiv."
        ),
        h3("Simulations in the Manuscript"),
        p(
          "All scripts and instructions to reproduce the analyses in the manuscript can be found in the",
          a(href = "https://github.com/solislemuslab/minaa/tree/main/simulations", "simulations folder"),
          "on Github."
        ),
        
        h2("Contributions, Questions, Issues, and Feedback"),
        p(
          "Users interested in expanding functionalities in MiNAA are welcome to do so. Issues reports are encouraged through the",
          a(href = "https://github.com/solislemuslab/minaa/issues", "issue tracker"),
          "on Github. See details on how to contribute and report issues in",
          a(href = "https://github.com/solislemuslab/minaa/blob/master/CONTRIBUTING.md", "CONTRIBUTING.md"),
          "on Github."
        ),
        
        h2("License"),
        p(
          "MiNAA is licensed under the",
          a(href = "https://opensource.org/licenses/MIT", "MIT License"),
          "\U00A9 Sol\U00EDs-Lemus Lab (2025)."
        )
    )
  )
)


