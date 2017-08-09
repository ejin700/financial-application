# author:   Sameer Jain
# github:   @sameerjain97
# date:     05-13-2017
# project:  financial-application
# function: calculate-log-returns
# criteria:
#   - import closing prices for period of polling data 
#   - observations counted chronologially
#   - exports csv to ../financial-application/data-engineering

library(dplyr)
library(quantmod)
library(data.table)

#import financial data for time period
getSymbols("FB")
FB = FB['2015-12-16::2016-10-27']
FB = as_data_frame(FB)
FB = tibble::rownames_to_column(FB)
names(FB)[names(FB) == 'rowname'] <- 'enddate'

FB = select(FB, enddate, FB.Close)

#calculate log return
FB = mutate(FB, lag = FB.Close)
FB$lag = Lag(FB$lag, k = 1)
FB = mutate(FB, log.return = (log(FB.Close)-log(lag)))

FB = filter(FB, enddate != "2015-12-16")

#create new column for observation number
FB$observation <- 1:nrow(FB)

write.csv(FB, file = "logreturns_FB.csv")