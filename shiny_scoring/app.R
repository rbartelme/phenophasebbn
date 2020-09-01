library(shiny)
library(tidyverse)
library(bnlearn)
library(Rgraphviz)
library(shinythemes)

# ===========================================================
# place holder HelloShiny example from
# https://shiny.rstudio.com/tutorial/written-tutorial/lesson1/
# ===========================================================

#load fitted network
net <- s4_hc_fit2
# Define UI for app that draws a histogram ----
ui <- fluidPage(theme = shinytheme("superhero"),

  # App title ----
  titlePanel(div(HTML("<em>Sorghum bicolor</em><br>Bayesian Network"))),

# 07-01-2020 UI notes:
# this is probably better as a "fluid row"
# specify the rows to be the columns specified in the mockup svg
# plot the network structure in the center
# could pick site/seasons from a dynamic side column?
# or this could be tabs at the top of the page

  # Sidebar layout with input and output definitions ----
  sidebarLayout(

    # Sidebar panel for inputs ----
    sidebarPanel(

      # Need to change this to select graph
        #options are A_manual or B_learned

      # Input: Slider for the number of bins ----
      selectInput(inputId = "Node",
                  label = "Highlight Nodes:",
                  choices = names(net),
                  selected = NULL,
                  multiple = TRUE,
                  selectize = TRUE,
                  width = NULL,
                  size = NULL ),
      width = 3),

    # Main panel for displaying outputs ----
    mainPanel(
      #Main panel should display 2 plot outputs
      # 1) DAG's
      # 2) diagnostic plots by node
        # this is done using score(..., by.node = TRUE, ...)
        # And plotting the results
      # 3) subheading similarity of graphs from bnlearn function
        # This can be summarized with:
        # all.equal(A,B) - all nodes compared, returns boolean
      # compare network structures
        # graphviz.compare()
        # hamming() - will calculate the hamming distance between graph structures
      # query function:
      # this will need to be quite dynamic for the inputs
      # elseif for storing event vector?
        # cpquery(fitted,
        # event = ((A >= 0) & (A <= 1)) & ((B >= 0) & (B <= 3)),
        # evidence = (C + D < 10))

      # Output: network plot
      plotOutput(outputId = "netPlot", width = "100%",
                 height = "666px"),
          width = 9)
  )
)

# ===========================================================

# Define server logic required to draw a histogram ----
server <- function(input, output) {
  #input$Node <- 

  output$netPlot <- renderPlot({
      #load fitted network graph (from bnlearn_script)
   # if(is.null(input$Node)){
    g <- Rgraphviz::layoutGraph(bnlearn::as.graphNEL(net), layoutType = "dot")
    graph::nodeRenderInfo(g) <- list(fontsize=20, shape = "circle",
                                     height = 80, rWidth = 40, lWidth = 40,
                                  fixedsize = FALSE)
    graph::edgeRenderInfo(g) <- list(lwd = 3)
    Rgraphviz::renderGraph(g)
    #}
    #else() 
    })

}

#======================================
# App Declaration
#======================================
shinyApp(ui = ui, server = server)
