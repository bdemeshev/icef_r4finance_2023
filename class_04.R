# hi :)
# week 4 

# install these packages: Tools - Install Packs -
# imputeTS, anomalize, modeltime

# imputeTS = imputation = fill missing values 
# anomalize = remove outliers 
# modeltime alternative to fpp3 (arima, ets, arima + gradient boosting ...)

library(fpp3) # collection for forecasting purposes
library(rio) # import/export 
library(imputeTS) # impute missing values
library(lubridate) # working with dates

marr_all = import('marriages-clean.csv')
glimpse(marr_all)

marr_rf = filter(marr_all, code == 643)

marr_rf = mutate(marr_rf, d = yearmonth(paste0(year, '-', month_no, '-01')))
glimpse(marr_rf)

marr_rf_ts = as_tsibble(marr_rf, index = d)
glimpse(marr_rf_ts)

gg_tsdisplay(marr_rf_ts, marriage)

# create artificial gaps
where_gaps = c(5:6, 40:45, 90:92, 150:151, 170)
marr_rf_ts = mutate(marr_rf_ts, marriage2 = marriage)
glimpse(marr_rf_ts)

marr_rf_ts$marriage2[where_gaps] = NA

gg_tsdisplay(marr_rf_ts, marriage2)


