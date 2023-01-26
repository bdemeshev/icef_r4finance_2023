# https://fedstat.ru/indicator/33553

# clean data ~ 90%
# ETS/ARIMA ~ 10%

url = 'https://github.com/bdemeshev/webinar_eusp_forecasting_r_2021_03_13/raw/main/original_data.xls'

library(fpp3) # collection of packages to work with time series
library(rio) # import/export various formats

# if you are lucky
# data = import('filename')
# if you are unlucky 
# step 1. use .csv format
# step 2. data = import('filename.csv')

data = import(url) # FAILS

# data = import('~/Downloads/original_data.xls')
data = import('~/Documents/icef_r4finance_2023/marriages-orig.csv')

head(data)
tail(data)

colnames(data) = data[3, ]
glimpse(data)
colnames(data) = c('code_region', 'unit', 'period', 2006:2020)

d2 = data[-(1:3), ]


unique(d2$code_region)
# split column into code and region

unique(d2$unit)
# junk column

unique(d2$period)
# remove aggregate rows
# use month numbers instead of names and strange codes


d3 = select(d2, -unit)
glimpse(d3)

