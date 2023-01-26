library(fpp3) # time series functions
library(rio) # import-export
library(stringr)

marriage = import('~/Documents/icef_r4finance_2023/marriages-clean.csv')
glimpse(marriage)

m2 = mutate(marriage, date = ymd(paste0(year, '-', month_no, '-01')))
glimpse(m2)
m3 = mutate(m2, date2 = yearmonth(date))
glimpse(m3)

m4 = select(m3, -month_no, -year, -date)

# m_final_bad = as_tsibble(m4, index=date2)

m_final = as_tsibble(m4, index=date2, key=code)
glimpse(m_final)

filter(m_final, str_detect(region, 'Москва'))
# 45000000000

rus = filter(m_final, code %in% c(643, 45000000000))

autoplot(rus) # automatic plot

gg_tsdisplay(filter(rus, code == 643), marriage)

gg_lag(filter(rus, code == 643), marriage, lags = 1:12)
?gg_lag

# sACF = sample autocorrelation function
# estimate of correlation Corr(y_t, y_{t+k})

tail(rus)

rus_train = filter(rus, date2 < ymd('2019-01-01'))
rus_test = filter(rus, date2 >= ymd('2019-01-01'))

glimpse(rus_train)
glimpse(rus_test)

# we can use m_final here (it will take a lot of time!)
mod_table = model(rus_train, 
            naive = SNAIVE(marriage),
            ets_aaa = ETS(marriage ~ error('A') + trend('A') + season('A')),
            ets_aaa_ln = ETS(log(marriage) ~ error('A') + trend('A') + season('A')),
            ets_auto = ETS(marriage)) 

mod_table

mod_table %>% filter(code == 643) %>% select(ets_aaa) %>% report()
# google: otext fpp3
# https://otexts.com/fpp3/
# https://otexts.com/fpp3/ets.html


cmpnts = mod_table %>% filter(code == 643) %>% 
  select(ets_aaa) %>% components()
cmpnts %>% autoplot()


frcsts = forecast(mod_table, h = '2 years')


frcsts %>% filter(.model %in% c('naive', 'ets_auto'),
                  code == 643) %>% autoplot()

frcsts %>% filter(.model %in% c('naive', 'ets_auto'),
                  code == 643) %>% 
      autoplot(rus_train)

frcsts %>% filter(.model %in% c('naive', 'ets_auto'),
                  code == 643) %>% 
  autoplot(filter(rus_train, date2 >= ymd('2012-01-01')))


acc = accuracy(frcsts, rus)

acc %>% arrange(code, MAE)


mod_table2 = model(rus_train, 
                   sarima111_111 = ARIMA(log(marriage) ~ 1 + pdq(1, 1, 1) + PDQ(1, 1, 1)),
                   sarima111_101 = ARIMA(log(marriage) ~ 1 + pdq(1, 1, 1) + PDQ(1, 0, 1)),
                   auto_arima = ARIMA(marriage))

select(mod_table2, auto_arima) %>% filter(code == 643) %>% report()
