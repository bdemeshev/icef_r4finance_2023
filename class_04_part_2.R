# short intro to modeltime
library(tidymodels)
library(modeltime) # alternative to fpp3
library(tidyverse)
library(lubridate)
library(timetk)
library(rio)

marr = import('marriages-clean.csv')
glimpse(marr)
marr = mutate(marr, d = ymd(paste0(year, '-', month_no, '-01')))
glimpse(marr)

marr = arrange(marr, code, d)
rf = filter(marr, code == 643)
glimpse(rf)

plot_time_series(rf, d, marriage)

tt_split = initial_time_split(rf, prop = 0.8)

auto_arima_mod = arima_reg() %>%
  set_engine(engine = 'auto_arima') %>%
  fit(marriage ~ d, data = training(tt_split))




arima_xb_mod = arima_boost(min_n=3, learn_rate = 0.02) %>%
  set_engine(engine='auto_arima_xgboost') %>%
  fit(marriage ~ d + as.numeric(d) + factor(month_no, ordered = FALSE),
      data = training(tt_split))
  
ets_mod = exp_smoothing() %>%
  set_engine(engine='ets') %>%
  fit(marriage ~ d, data = training(tt_split))

mod_all = modeltime_table(auto_arima_mod, 
                          arima_xb_mod,
                          ets_mod)

mod_all


# fpp3: https://otexts.com/fpp3/
# Rob Hyndman [academic]
# modeltime: https://business-science.github.io/modeltime/
# Matt Dancho [business]







