# author:   Sameer Jain
# github:   @sameerjain97
# date:     05-14-2017
# project:  financial-application
# function: create CSV for linear regression
# criteria:
#   - import ipsos polling data and log returns data
#   - observations counted chronologially
#   - exports csv to ../financial-application/data-engineering
#   - eliminate weekend variables 

# Pseudocode for left join Script:
# df1, df2 where df1 contains stock info
# final_data <- one_stock (choose a stock to fix the dates)
# for stock in all_stocks:
#   stock <- stock %>% mutate(enddate=as.Date(enddate))
#   final_data <- left_join(final_data, stock, by="enddate")

FB = read.csv("logreturns_FB.csv")
POLL = read.csv("ipsos-polling-data.csv")

FB = FB %>% mutate(enddate = as.Date(enddate))
POLL = POLL %>% mutate(enddate = as.Date(enddate))
combined = left_join(FB, POLL, by = "enddate")

write.csv(combined, file = "combined_FB.csv")