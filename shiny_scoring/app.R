library(shiny)
library(tidyverse)
#library(bnlearn)
#library(graphviz)

# ===========================================================
# place holder HelloShiny example from
# https://shiny.rstudio.com/tutorial/written-tutorial/lesson1/
# ===========================================================

# Define UI for app that draws a histogram ----
ui <- fluidPage(

  # App title ----
  titlePanel("Hello Shiny!"),

  # Sidebar layout with input and output definitions ----
  sidebarLayout(

    # Sidebar panel for inputs ----
    sidebarPanel(

      # Need to change this to select graph
        #options are A_manual or B_learned

      # Input: Slider for the number of bins ----
      sliderInput(inputId = "bins",
                  label = "Number of bins:",
                  min = 1,
                  max = 50,
                  value = 30)

    ),

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
        # hamming() - will calculate the hamming distance between graph structures
        # graphviz.compare()
      # Output: Histogram ----
      plotOutput(outputId = "distPlot")

    )
  )
)

# ===========================================================

# Define server logic required to draw a histogram ----
server <- function(input, output) {

  # Histogram of the Old Faithful Geyser Data ----
  # with requested number of bins
  # This expression that generates a histogram is wrapped in a call
  # to renderPlot to indicate that:
  #
  # 1. It is "reactive" and therefore should be automatically
  #    re-executed when inputs (input$bins) change
  # 2. Its output type is a plot

  # The server function will be redefined by if elseif else statements
  # Similar to what was implemented in the AZCOVID text project

  output$distPlot <- renderPlot({

    x    <- faithful$waiting
    bins <- seq(min(x), max(x), length.out = input$bins + 1)

    hist(x, breaks = bins, col = "#75AADB", border = "white",
         xlab = "Waiting time to next eruption (in mins)",
         main = "Histogram of waiting times")

    })

}

#======================================
# App Declaration
#======================================
shinyApp(ui = ui, server = server)
