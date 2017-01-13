library(shiny)
library(shinyjs)

ui <- fluidPage(
  useShinyjs(),
  titlePanel("Bakery Dataset (Association Rules)"),
  sidebarLayout(
    sidebarPanel(
      helpText("Explore the data!"),br(),
      selectInput("TypeOfGraph",
                label = "Type:",
                choices = c("Basic Data Plot", "Basic Data Plot with facet"),
                selected = "Basic Data Plot")
    ),
    mainPanel(
      plotOutput("bar")
    )
  ),
  sidebarLayout(
    sidebarPanel(
      helpText("Time for some Association Rules Mining!"),br(),
      selectInput("TypeOfData",
                  label = "Data To be Mined: ",
                  choices = c("Food", "Flavor", "Type of Food"),
                  selected = "Food"),
      sliderInput(inputId="conf_value", 
                  label="Confidence:", 
                  min=0.7, max=0.99, value=0.8, step=1/100000),br(),
      sliderInput(inputId="supp_value", 
                  label="Support:", 
                  min=0.01, max=0.03, value=0.015, step=1/100000),br(),
      checkboxInput(inputId = "lift_control", label = "Lift filter", value=FALSE),
      conditionalPanel(
        condition = "input.lift_control == true",
        sliderInput(inputId="lift_value", 
                    label="Filter(according to top lift):", 
                    min=1, max=30, value=15, step=1)
      ),br(),
      selectInput("TypeOfPlot",
                  label = "Type:",
                  choices = c("Scatter", "Scatter(Lift as parameter)", "Grouped", "Graph", "Parallel Coordinates", "Matrixs"),
                  selected = "Scatter")
    ),
    mainPanel(
      plotOutput("plot"),
      plotOutput("time")
    )
  )
)