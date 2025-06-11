AboutTab <- tabPanel(
  "About",
  style = "
    max-width: 100%;
  ",
  fluidPage(
    tags$head(
      tags$style(HTML("
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
    div(
      style = "
        background-color: #f9f9f9;
        border: 1px solid #ddd;
        padding: 20px;
        border-radius: 10px;
        margin: 20px auto;
      ",
      h2("About MiNAA"),
      p("MiNAA aligns two networks based on their topologies and biologies."),
      p(
        "The source code for this web app is available on ",
        a(href = "https://github.com/solislemuslab/minaa-webapp", "GitHub"),
        "."
      ),
      h3("Introduction Video"),
      tags$iframe(
        src = "https://www.youtube-nocookie.com/embed/S9PaA49xyBU", # No-cookie embed link
        width = "480", # Smaller width
        height = "270", # Maintain 16:9 aspect ratio
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
        tags$li("G-H/: (where G, H are the input networks) The folder containing the output files specified below."),
        tags$li("log.txt: Record of the important details from the alignment."),
        tags$li("G_gdvs.csv: (where G is the input network) The Graphlet Degree Vectors for network G."),
        tags$li("H_gdvs.csv: (where H is the input network) The Graphlet Degree Vectors for network H."),
        tags$li("top_costs.csv: The topological cost matrix."),
        tags$li("bio_costs.csv: The biological cost matrix (as inputed). Not created unless biological input is given."),
        tags$li("overall_costs.csv: The combination of the topological and biological cost matrix. Not created unless biological input is given."),
        tags$li("alignment_list.csv: A complete list of all aligned nodes, with rows in the format `g_node,h_node,similarity`, descending according to similarity. The first row in this list is the total cost of the alignment, or the sum of (1 - similarity) for all aligned pairs."),
        tags$li("alignment_matrix.csv: A matrix form of the same alignment, where the first column and row are the labels from the two input networks, respectively.")
      ),
      h2("Resources"),
      h3("Examples"),
      p(
        "For examples of file input format, parameter usage, and expected outputs for MiNAA, see the",
        a(href = "https://github.com/solislemuslab/minaa/tree/main/examples", "examples folder"),
        "on Github."
      ),
      h3("Software Note"),
      p(
        "For a more detailed description of the MiNAA Web App, a",
        a(href = "#", "Software Note"),
        "is published in the Journal of Open Source Software."
      ),
      h3("Citation"),
      p(
        "For citation information for both the MiNAA algorithm and MiNAA web app, please refer to the ",
        a(href = "https://github.com/solislemuslab/minaa-webapp#citation", "Citation section on GitHub"),
        "."
      ),
      h2("Contributions, Questions, Issues, and Feedback"),
      p(
        "Users interested in expanding functionalities in MiNAA are welcome to do so. Issues reports are encouraged through the",
        a(href = "https://github.com/solislemuslab/minaa-webapp/issues", "issue tracker"),
        "on Github. See details on how to contribute and report issues in",
        a(href = "https://github.com/Sophiayangg/minaa-webapp/blob/main/CONTRIBUTING.md", "CONTRIBUTING.md"),
        "on Github. Contributions to",
        a(href = "https://github.com/solislemuslab/minaa-webapp", "this webapp"),
        "are also welcome."
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
