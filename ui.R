# h1(span("MiNAA", style = "font-weight: 300"),
#    style = "font-family: 'Source Sans Pro';
#       color: #000000; text-align: center;
#       padding: 20px"),
# br(),

# RESOURCES
# https://wi-fast-stats.wid.wisc.edu/
# https://github.com/crsl4/fast-stats/tree/master/shiny-app/webinar-aug20
# https://wi-fast-stats.wid.wisc.edu/cotyledon/

source("alignTab.R")
source("resultsTab.R")
source("visualizeTab.R")
source("aboutTab.R")

navbarPage(
  img(
    src = "logo.png",
    height = "24px",
    style = "display: block; margin-left: auto; margin-right: auto; padding: -8px"
  ),
  AlignTab,
  ResultsTab,
  VisualizeTab,
  AboutTab
  # ,
  # tags$footer("My footer", align = "center", style = "
  #             position:absolute;
  #             bottom:0;
  #             width:100%;
  #             height:50px;   /* Height of the footer */
  #             color: white;
  #             padding: 10px;
  #             background-color: gray;
  #             z-index: 1000;")
)
