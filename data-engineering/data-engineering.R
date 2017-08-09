# author:   Sameer Jain
# github:   @sameerjain97
# date:     05-13-2017
# project:  financial-application
# function: Strips presidential polling data for use in project
# criteria:
#   - limited to one pollster
#   - sorted by date
#   - observations counted chronologially
#   - startdate and enddate have constant difference of 4 days
#   - exports csv to ../financial-application

library(data.table)
library(ggplot2)
library(dplyr)

#import CSV and create poll data frame
poll = read.csv("presidential_polls.csv")

#limit to national polls and Ipsos
#filter columns of interest
poll = filter(poll, state == "U.S.")
poll = select(poll, startdate, enddate, pollster, adjpoll_clinton, adjpoll_trump)
poll = filter(poll, pollster == "Ipsos")
poll = arrange(poll, enddate)

#reformat dates into more readable form
poll$enddate = as.Date(as.factor(poll$enddate), "%m/%d/%Y")
poll$startdate = as.Date(as.factor(poll$startdate), "%m/%d/%Y")
poll = arrange(poll, enddate)

#groups polling data by enddate
poll = group_by(poll, enddate)

#randomly select one poll data point on each day
poll = sample_n(poll, 1)

#create new column for observation number
poll$observation <- 1:nrow(poll)

#outputs CSV to ../financial-application
write.csv(poll, file = "ipsos-polling-data.csv")