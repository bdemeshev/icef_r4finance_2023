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


ggplot_na_distribution(marr_rf_ts$marriage2)
ggplot_na_distribution2(marr_rf_ts$marriage2)

# simple linear imputation
marr_imp = na_interpolation(marr_rf_ts$marriage2)

ggplot_na_imputations(marr_rf_ts$marriage2, marr_imp)


# imputation using conditional expected value for arima model

# boring type conversion :(
marr_old = as.ts(marr_rf_ts)
marr2 = marr_old[, 6]
marr2

mod = arima(marr2, order = c(1, 1, 0),
            seasonal = list(order = c(0, 1, 0)))$model
mod

# mod_bad = arima(marr_rf_ts$marriage2, order = c(0, 1, 0),
#      seasonal = list(order = c(0, 1, 0)))$model

marr_imp2 = na_kalman(marr2, model=mod)

ggplot_na_imputations(marr_rf_ts$marriage2, marr_imp2)

# imputation with auto arima
marr_imp3 = na_kalman(marr2, model='auto.arima')

ggplot_na_imputations(marr_rf_ts$marriage2, marr_imp3)
