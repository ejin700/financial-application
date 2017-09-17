
# Financial Application for Stock Data
Final Project for IEOR 4307 (Applied Statistical Models in OR), Spring 2017

## Webpage
The working financial application is available [online](http://35.185.101.230:5050/) once the programming is runing. In addition, the financial application can be downloaded locally from Github and run in RStudio. 

## Project Details
This project in an interactive web application that analyzes stock data for 10 publically traded companies (APPL, AMZN, etc.). It also compares Donald J. Trump's polling data from the 2016 election cycle to changes in the stock market in order to test for any correlation.

When only one stock symbol is selected, this app displays histograms for Open, High, Low, Close, and Volume values. It also displays a normal probability plot, performs a goodness-of-fit test for normality, and creates approximate confidence intervals for the means and variances given a user-specified confidence level. Finally, it performs a regression of the log-returns over time.

When the user selects two stock symbols, the app is able to test the equality of the two population means (for Open, High, Low, Close, and Volume), test for independence of the log-returns, and perform a regression of one log-return on the other.

All regression outputs include intercepts and slope estimates, a diagram of the data with the least-squares line, a graphical depition of the residual values, and an R^2 value.

## Data Sources
Financial data was extracted via the [quantmod](http://www.quantmod.com/) financial package and Google Finance's stock market data. This project also utilizes the publicly available [2016 Election Polls](https://www.kaggle.com/fivethirtyeight/2016-election-polls) data set from FiveThirtyEight.  [2016 General Election Polling Data](https://projects.fivethirtyeight.com/2016-election-forecast/?ex_cid=rrpromo#plus) was found on FiveThirtyEight's *Who will win the presidency?* homepage. 

## Technology
This project was created in the R programming language and used [Shiny](https://shiny.rstudio.com/) by RStudio, a web application framework for R, that helps turn analyses into an interactive web application. The project was originally hosted on the Google Cloud Platform. 
