# https://fedstat.ru/indicator/33553

# clean data ~ 90%
# ETS/ARIMA ~ 10%

url = 'https://github.com/bdemeshev/webinar_eusp_forecasting_r_2021_03_13/raw/main/original_data.xls'

library(fpp3) # collection of packages to work with time series
library(rio) # import/export various formats
library(stringr) # string operations

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
# split column into code and region [SOLVED]

unique(d2$unit)
# junk column [SOLVED]

# years are in different columns!

unique(d2$period)
# remove aggregate rows [SOLVED]
# use month numbers instead of names and strange codes [SOLVED]


d3 = select(d2, -unit)
# old syntax: 
# d3 = d2[, -2]
glimpse(d3)

?select
d4 = mutate(d3, code_region = str_trim(code_region))
unique(d4$code_region)


?separate

d5 = separate(d4, code_region, into = c('code', 'region'),
              sep = ' ', extra = 'merge')
glimpse(d5)

d6 = mutate(d5, code = as.numeric(code))
glimpse(d6)

unique(d6$period)

?str_detect
str_detect(d6$period, '-')

d7 = filter(d6, !str_detect(period, '-'))
unique(d7$period)
glimpse(d6)
glimpse(d7)

dict = tibble(period = unique(d7$period), month_no = 1:12)
dict
glimpse(dict)
glimpse(d7)

d8 = left_join(d7, dict, by = 'period')
glimpse(d8)

d9 = select(d8, -period)

# pivot_longer, pivot_wider

?pivot_longer

d10 = pivot_longer(d9, `2006`:`2020`, 
                names_to = 'year', values_to = 'marriage')
glimpse(d10)


# remove comma and transform marrige into numeric
d11 = mutate(d10, marriage = as.numeric(str_remove(marriage, ',')))

glimpse(d11)

d12 =  mutate(d11, year = as.numeric(year))
d12

export(d12, '~/Documents/icef_r4finance_2023/marriages-clean.csv')

