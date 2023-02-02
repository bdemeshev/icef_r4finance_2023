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
library(anomalize) # remove outliers

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

# task 2. Remove outliers

where_out = c(55, 111, 150)
marr_rf_ts = mutate(marr_rf_ts, marriage3 = marriage)
marr_rf_ts$marriage3[where_out] = 5 * 10^5

gg_tsdisplay(marr_rf_ts, marriage3)

# idea: 
# decompose time series
# remove outlier in components
# combine components back

# special type of column with information
marr_rf_ts = mutate(marr_rf_ts, date = as.Date(d))

marr_comp = time_decompose(marr_rf_ts, marriage3)
# to remove outlier replace remainder with zero!
?time_decompose

# STL approach 
marr_out = anomalize(marr_comp, target = remainder)
plot_anomalies(marr_out)

filter(marr_out, anomaly == 'Yes')

marr_recons = time_recompose(marr_out)
marr_final = clean_anomalies(marr_recons)

marr_rf_ts$marriage4 = marr_final$observed_cleaned
gg_tsdisplay(marr_rf_ts, marriage4)

autoplot(marr_rf_ts, marriage)

autoplot(marr_rf_ts, marriage4)

autoplot(marr_rf_ts, marriage3)

# intermittent demand models
# hidden states model
