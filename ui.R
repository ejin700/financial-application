#define UI for financial application
library(shiny)

#load in csvs, and get nice list of stock names for display
files <- list.files(pattern="*.csv")
stocks <- list()
j <- 1
for (file in files) {
  if (nchar(file) < 10) {
    stocks[[j]] <- file
    j <- j+1
  }
}
stock_names <- list()
i <- 1
while (i < (length(stocks)+1)) {
  name <- sub(".csv","",stocks[i])
  stock_names[[i]] <- toupper(name)
  i <- i+1
}

#define UI page layout and display
shinyUI(fluidPage(
  headerPanel("IEOR 4307: Financial App", "Financial App"),
  
  #gather user input from side panel
  sidebarPanel(
    selectInput("stock", "Select a Stock: ", choices = stock_names),
    selectInput("data", "Select a Dataset: ", choices = c("Open","High","Low","Close","Volume")),
    sliderInput("level", "Confidence Level: ", min = 0, max = 99, value = 95),
    selectInput("stock2", "(Optional) Select Another Stock to Compare: ", choices=stock_names)
  ),
   
  #display dynamic results in main panel
  mainPanel(
    tabsetPanel (
      #Single stock analysis
      tabPanel("Stock Data Analysis",
               plotOutput("hist"),
               tableOutput("interval"),
               tableOutput("varInterval"),
               plotOutput("norm"),
               tableOutput("chisq"),
               plotOutput("line"),
               tableOutput("summary"),
               plotOutput("resid")),
      #Two stock analysis
      tabPanel("Two Stock Analysis",
               tableOutput("meanTest"),
               plotOutput("cmpline"),
               tableOutput("regTest"),
               plotOutput("cmpresid")),
      #Trump Analysis
      tabPanel("Trump Approval Ratings Analysis",
               plotOutput("trumpline"),
               tableOutput("trumpreg"),
               plotOutput("trumpresid"))
    )
  ) 
))
