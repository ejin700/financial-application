import csv

with open("ipsos-polling-data.csv") as pollfile:
	
	with open("XOM-logreturns.csv") as stockfile:
	
		pollCSV = csv.reader(pollfile, delimiter = ',')
		stockCSV = csv.reader(stockfile, delimiter = ',')
		
		#arrays to be appended from polling data
		enddate = []
		adjpoll_clinton = []
		adjpoll_trump = []
		
		#arrays to be appended from stock data
		logreturns = []
		
		for poll_row in pollCSV:

			curr_poll_enddate = poll_row[2]
			curr_adjpoll_clinton = poll_row[4]
			curr_adjpoll_trump = poll_row[5]
			
			for stock_row in stockCSV:
				
				curr_stock_enddate = stock_row[1]
				curr_logreturn = stock_row[4]
				
				print(curr_poll_enddate)
				print(curr_stock_enddate)
				
#				if(curr_poll_enddate == curr_stock_enddate):
					
#					enddate.append(curr_poll_enddate)
#					adjpoll_clinton.append(curr_adjpoll_clinton)
#					adjpoll_trump.append(curr_adjpoll_trump)
#					log.returns.append(curr_logreturn)
		
#					with open("AAPL-poll-data.csv", 'w') as saveFile:
#						saveFileWriter = csv.writer(saveFile)
#						saveFileWriter.writerow([curr_poll_enddate, curr_adjpoll_clinton, curr_adjpoll_trump, curr_logreturn])


pollfile.close()
stockfile.close()
#saveFile.close()


			
		
	

	

		



