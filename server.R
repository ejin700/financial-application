#define server logic for financial application
library(shiny)

shinyServer(function(input, output, session) {
  
  #Accepts input stock
  dataUpload <- reactive({
    file_name <- paste(tolower(input$stock),".csv",sep="")
    dt_frame <- read.csv(file_name)
    updateSelectInput(session, "stock")
    return(dt_frame)
  })
  
  #Accepts second stock
  dataUpload2 <- reactive({
    file_name <- paste(tolower(input$stock2),".csv",sep="")
    dt_frame2 <- read.csv(file_name)
    updateSelectInput(session,"stock2")
    return(dt_frame2)
  })
  
  #Read in stock/polling data csv
  dataUpload3 <- reactive ({
    file_name <- paste(input$stock,".csv",sep="")
    path_name <- paste("combined_",file_name,sep="")
    dt_frame3 <- read.csv(path_name)
    updateSelectInput(session,"stock")
    return(dt_frame3)
  })
  
  #Creates histogram for high stock data taking the selected input from dropdown
  output$hist <- renderPlot({
    dataset <- dataUpload()
    stock.log = diff(log(dataset[,input$data]), lag = 1)
    plot.title <- paste("Histogram of Stock ",input$data,sep="")
    Title <- paste(plot.title,"Log Returns",sep=" ")
    hist(stock.log, xlab = "Log Stock Data", ylab = "Frequency", main = Title, 20, col = 'skyblue')
  })
   
  #construct CI for mean given input confidence level
  output$interval <- renderTable({
    dataset <- dataUpload() 
    stock.log = diff(log(dataset[,input$data]), lag = 1)
    
    m <- mean(stock.log)
    s <- sd(stock.log)
    n <- length(stock.log)
    error <- qnorm(1-(1-input$level/100)/2)*s/sqrt(n)
    lb <- m-error
    rb <- m+error
    
    out <- data.frame(
      lb = as.character(lb),
      ub = as.character(rb))
    colnames(out) <- c("Lower Bound","Upper Bound")
    out 
    },
    caption = "Confidence Interval for Mean: ",
    caption.placement = getOption("xtable.caption.placement", "top"), 
    caption.width = getOption("xtable.caption.width", NULL)
  )
  
  #construct CI for variance given input confidence level
  output$varInterval <- renderTable({
    dataset <- dataUpload()
    stock.log = diff(log(dataset[,input$data]), lag = 1)
    
    s <- sd(stock.log)
    dF <- length(stock.log) - 1
    al <- 1- (100-input$level)/200
    au = (100-input$level)/200
    lb <- (dF*s)/qchisq(al, df = dF)
    ub <- (dF*s)/qchisq(au, df = dF)
    
    out <- data.frame(
      lb = as.character(lb),
      ub = as.character(ub))
    colnames(out) <- c("Lower Bound","Upper Bound")
    out 
    },
    caption = "Confidence Interval for Variance: ",
    caption.placement = getOption("xtable.caption.placement", "top"), 
    caption.width = getOption("xtable.caption.width", NULL)
  )
  
  #Creates normality plot for the log return
  output$norm <- renderPlot({
    dataset <- dataUpload()
    stock.log = diff(log(dataset[,input$data]), lag = 1)
    plot.title <- paste("Normality Plot of Stock ",input$data,sep="")
    Title <- paste(plot.title,"Log Returns",sep=" ")
    qqnorm(stock.log, xlab = "Theoretical Quantiles", ylab = "Observed Quantiles", main = Title, col = 'pink')
    qqline(stock.log)
  })
  
  #Goodness of fit test for normality
  output$chisq <- renderTable({
    dataset <- dataUpload() 
    stock.log = diff(log(dataset[,input$data]), lag = 1)
    
    m <- mean(stock.log)
    s <- sd(stock.log)
    n <- length(stock.log)
    
    #get observed frequencies
    test <- hist(stock.log, 20)
    breaks <- test$breaks
    nBins <- length(breaks) - 1
    observed <- test$counts
    
    #get expected frequencies
    expected <- 0
    for(i in 1:nBins){
      expected[i] <- (pnorm(breaks[i+1], m, s) - (pnorm(breaks[i], m, s)))*(length(stock.log)+1)
    }
    
    #put it through the formula: observedTest = (observed-expected)^2 / expected
    testStat <- 0
    if(nBins < 20){
      for(i in 1:nBins){
        if(nBins - 4 < i ) {
          testStat[i] <- 0
        } else if(i < 5) {
          testStat[i] <- 0
        } else {
          testStat[i] <- (observed[i]-expected[i])^2 / expected[i]
        }
      }
    }
    
    #prevents outliers from skewing test statistic
    if(nBins > 19){
      for(i in 1:nBins){
        if(nBins - 6 < i ){
          testStat[i] <- 0
        } else if(i < 7){
          testStat[i] <- 0
        } else {
          testStat[i] <- (observed[i]-expected[i])^2 / expected[i]
        }
      }
    }

    finalStat <- sum(testStat)

    #find the table chi square value at the given confidence level
    dF <- nBins - 1
    a <- input$level/100
    chiValue <- qchisq(a, df = dF)

    #reject null hypothesis that distribution is normal if calculated test statistic is greater than the table chi squared value
    conclusion <- "Not Reject"
    if (finalStat > chiValue) {
      conclusion <- "Reject"
    }

    out <- data.frame(
      Test_Statistic = as.character(finalStat),
      Chi_Squared_Critical_Value = as.character(chiValue),
      Conclusion = as.character(conclusion))
    colnames(out) <- c("Test Statistic","Chi-Squared Critical Value","Conclusion")
    out
    }, 
    caption = "Goodness of Fit Test for Normality (H0: Data is normally distributed):",
    caption.placement = getOption("xtable.caption.placement", "top"), 
    caption.width = getOption("xtable.caption.width", NULL)
  )

  #Linear regression plot and line for price vs. time
  output$line <- renderPlot({
    dataset <- dataUpload()
    prices.day.log <- diff(log(dataset[,input$data]), lag = 1)
    a <- c(1:length(prices.day.log))
    price.lm = lm(prices.day.log ~ a, data = dataset)
    plot(prices.day.log ~ a, data = dataset, xlab = "Day", ylab = input$data, main = "Least Squares Regression")
    abline(price.lm)
  })
  
  #output important data from linear regression of price vs. time
  output$summary <- renderTable({
    dataset <- dataUpload()
    prices.day.log <- diff(log(dataset[,input$data]), lag = 1)
    length(prices.day.log)
    a <- c(1:length(prices.day.log))
    price.lm = lm(prices.day.log ~ a, data = dataset)
    
    intercept <- summary(price.lm)$coefficients[1]
    slope <- summary(price.lm)$coefficients[2][1]
    r <- summary(price.lm)$r.squared
    p <- summary(price.lm)$coefficients[4]
    
    out <- data.frame(
      Slope_Estimate = as.character(slope),
      Intercept_Estimate = as.character(intercept),
      R_Squared = as.character(r),
      p_value = as.character(p))
    colnames(out) <- c("Slope Estimate","Intercept Estimate","R Squared Value","p Value")
    out
    },
    caption = "Linear Regression Analysis:",
    caption.placement = getOption("xtable.caption.placement", "top"), 
    caption.width = getOption("xtable.caption.width", NULL)
  )
  
  #Residual Plot for time vs. price
  output$resid <- renderPlot({
    dataset <- dataUpload()
    prices.day.log <- diff(log(dataset[,input$data]), lag = 1)
    a <- c(1:length(prices.day.log))
    price.lm = lm(prices.day.log ~ a, data = dataset)
    price.res = resid(price.lm)
    plot(a, price.res, ylab="Residuals", xlab="Day", main= "Residual Plot") 
    abline(0,0)
  })
  
#ANALYSIS FOR 2 STOCKS
  
  #test for difference of means of two stocks using Welch Two-Sample t-test
  output$meanTest <- renderTable({
    d1 <- dataUpload()
    d2 <- dataUpload2()
    x <- diff(log(d1[,input$data]), lag = 1)
    y <- diff(log(d2[,input$data]), lag = 1)
    
    ttest <- t.test(x,y)
    p <- ttest[['p.value']]
    x_name <- paste(input$stock, "Mean", sep=" ")
    y_name <- paste(input$stock2, "Mean", sep=" ")
    x_m <- ttest[['estimate']][1]
    y_m <- ttest[['estimate']][2]

    out <- data.frame(
      x_name = as.character(x_m),
      y_name = as.character(y_m),
      p_value = as.character(p))
    colnames(out) <- c(x_name,y_name,"p Value")
    out
    },
    caption = "Test for Difference of Means (H0: No difference):",
    caption.placement = getOption("xtable.caption.placement", "top"), 
    caption.width = getOption("xtable.caption.width", NULL)
  )
  
  #Linear regression plot and line for 2 stocks
  output$cmpline <- renderPlot({
    d1 <-dataUpload()
    d2 <-dataUpload2()
    y <- diff(log(d1[,input$data]), lag = 1)
    x <- diff(log(d2[,input$data]), lag = 1)
    
    price.lm = lm(y ~ x)
    plot(y ~ x, xlab = input$stock2, ylab = input$stock, main = "Least Squares Regression")
    abline(price.lm)
  })
  
  #test for independence (regression) of two stocks
  output$regTest <- renderTable({
    d1 <- dataUpload()
    d2 <- dataUpload2()
    y <- diff(log(d1[,input$data]), lag = 1)
    x <- diff(log(d2[,input$data]), lag = 1)
    
    linReg <- lm(y ~ x)
    intercept <- summary(linReg)$coefficients[1]
    slope <- summary(linReg)$coefficients[2][1]
    r <- summary(linReg)$r.squared
    p <- summary(linReg)$coefficients[4]
    
    out <- data.frame(
      Slope_Estimate = as.character(slope),
      Intercept_Estimate = as.character(intercept),
      R_Squared = as.character(r),
      p_value = as.character(p))
    colnames(out) <- c("Slope Estimate","Intercept Estimate","R Squared Value","p Value")
    out
    },
    caption = "Linear Regression Analysis (and Test for Independence): ",
    caption.placement = getOption("xtable.caption.placement", "top"), 
    caption.width = getOption("xtable.caption.width", NULL)
  )
  
  #Residual Plot for 2 stocks
  output$cmpresid <- renderPlot({
    d1<-dataUpload()
    d2<-dataUpload2()
    y <- diff(log(d1[,input$data]), lag = 1)
    x <- diff(log(d2[,input$data]), lag = 1)
    
    price.lm = lm(y ~ x)
    price.res = resid(price.lm)
    plot(price.res, xlab = "Data", ylab="Residuals", main= "Residual Plot") 
    abline(0,0)
  })
  
#TRUMP DATA ANALYSIS
  
  #Linear regression plot and line for log return vs. polling data
  output$trumpline <- renderPlot({
    dataset <- dataUpload3()
    y <- dataset[,6]
    x <- dataset[,12]
    
    price.lm = lm(y ~ x)
    plot(y ~ x, data = dataset, xlab = "Trump Polling Data", ylab = "Log Returns", main = "Least Squares Regression")
    abline(price.lm)
  })
  
  #output important data from linear regression of log return vs. polling data
  output$trumpreg <- renderTable({
    dataset <- dataUpload3()
    y <- dataset[,6]
    x <- dataset[,12]
    
    price.lm = lm(y ~ x)
    intercept <- summary(price.lm)$coefficients[1]
    slope <- summary(price.lm)$coefficients[2][1]
    r <- summary(price.lm)$r.squared
    p <- summary(price.lm)$coefficients[4]
    
    out <- data.frame(
      Slope_Estimate = as.character(slope),
      Intercept_Estimate = as.character(intercept),
      R_Squared = as.character(r),
      p_value = as.character(p))
    colnames(out) <- c("Slope Estimate","Intercept Estimate","R Squared Value","p Value")
    out
  },
  caption = "Linear Regression Analysis:",
  caption.placement = getOption("xtable.caption.placement", "top"), 
  caption.width = getOption("xtable.caption.width", NULL)
  )
  
  #Residual Plot for Trump polling data
  output$trumpresid <- renderPlot({
    dataset <- dataUpload3()
    y <- dataset[,6]
    x <- dataset[,12]
    
    price.lm = lm(y ~ x)
    price.res = resid(price.lm)
    plot(price.res, ylab="Residuals", xlab="Day", main= "Residual Plot") 
    abline(0,0)
  })
  
})
