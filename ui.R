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
)
