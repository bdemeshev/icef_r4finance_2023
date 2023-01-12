# let's start

# 2 parts: me + Dean Fantazzini
# my part: intro to R, 4 weeks
# datacamp 
# two mini-courses on datacamp

# web page of the course
# https://github.com/bdemeshev/icef_r4finance_2023/
  
# tg chat
# https://t.me/+M-2EsPzrZlYzYWVi

# packages! :)
# 1. how to install packages (once)
# 2. how to attach packages (every time you use it)

# tidyverse, rio, estimatr, skimr

# windows:
# compile packages from source?
# NO

library(tidyverse) # data manipulation, plots, ...
library(rio) # read many-many file formats
library(skimr) # descriptive statistics
library(estimatr) # robust inference in regression
library(lmtest) # many tests...

# ctrl + enter or cmd + enter to execute a line

# install.packages('rio')


a = 5 # my current style
b <- 7 # also a valid assignment style 
9 -> d # also a valid assignment style 

# learn to use TAB key!!!

library(estimatr) # libr <tab> esti <down> <tab>

my_lovely_variable = 8
my_lovely_variable # my_ <tab>

# minimal style guide
# 1. Space after comma
# 2. Space around math operators +, -, *, /

x=5+b+d # bad style
x = 5 + b + d # good style

# start from built-in dataset cars
# modify it
# save it 
# read it
# plots
# regression with robust se

help(cars)

d = cars
d
glimpse(d)
skim(d)
head(d, 7) # first observations
tail(d, 3) # last observations
head(d)

# * create new variables!

# classic style (similar to python)
d['log_speed'] = log(d['speed'])
head(d, 7)

# tidyverse style
d2 = mutate(d, speed2 = speed^2, speed3 = speed^3, cos_speed = cos(speed))
head(d2, 7)

# * rename variables
help(rename)
d3 = rename(d2, speed_squared = speed2, speed_cube = speed3)
head(d3)

# style: no spaces in variable names, use _ or . in variable name 
# start with letter not with number 
# bad name example
d3['1111 xyz'] = 7
head(d3)

# rename a variable with bad name :)
d4 = rename(d3, new_good_name = `1111 xyz`)
head(d4)

# * select columns

d5 = select(d3, speed, dist, speed_cube)
head(d5)

# you can select by column number, but avoid this approach
glimpse(d3)
d5alt = d3[, c(1, 2, 5)] # columns number 1, 2 and 5
d5alt

# * select rows
# basic old
d6 = d[d['speed'] > 15, ]
glimpse(d6)

# tidyverse style
d6alt = filter(d, speed > 15)
glimpse(d6alt)

d7 = filter(d, speed > 15, dist < 50)

# * access specific observation
d[5, 'speed']

d2[4, 'dist'] = NA # NA means Not Available (missing observation)
skim(d2)

# * read-write operations
# prefer the simplest .csv format
getwd()
setwd('/home/boris/Documents/icef_r4finance_2023/')
export(d2, file = 'demo_dataset.csv')

export(d2, file = 'demo_dataset.dta') # stata
export(d2, file = 'demo_dataset.xlsx') # excel


d2copy = import('demo_dataset.csv') # type: d2copy = imp <down> <tab> ' d <tab> ...
d2copy

# for big dataset: feather format 

# * plots

# one more built-in dataset: diamonds
help(diamonds)
glimpse(diamonds)
skim(diamonds)

unique(diamonds['cut'])
unique(diamonds['color'])

d = diamonds

# * scatterplot
qplot(data = d, x = carat, y = price)
plot1 = qplot(data = d, x = carat, y = price)

# the plot should be self-explanaroty!
plot2 = plot1 + labs(x = 'Weight of a diamond [carat]',
             y = 'Price of a diamond [dollar]', 
             title = 'Built-in R dataset on diamonds')
plot2

# * histogram
plot_b1 = qplot(data = d, x = price)
plot_b1 + labs(title = 'Built-in R dataset on diamonds', 
               x = 'Price of a diamond [dollar]')


# advice: spend a lot of time on plots!

# * regression
# python/r/gretl

# classic standard errors (should not be used!)
# homoscedasticity, Var(u_t |X) = const 

model_0 = lm(data = d, log(price) ~ log(carat) + x + y + z)
summary(model_0)
# se(beta_hat_log_carat) = 0.014


# use robust standard errors (always)
# heteroscedasticity, Var(u_t |X) = f(x_t)
model_a = lm_robust(data = d, log(price) ~ log(carat) + x + y + z)
summary(model_a)
# se_HC(beta_hat_log_carat) = 0.034

model_a[['coefficients']]
model_a[['std.error']]
model_a[['p.value']]
model_a[['conf.low']]
model_a[['conf.high']]

confint(model_a, level = 0.8)
coef(model_a)

str(model_a)

# * compare two nested models 
# simple (restricted model / short)
# complex (unrestricted model / long)

model_b = lm_robust(data = d, log(price) ~ log(carat) + x)

# H0: the restricted model is TRUE
# Ha: the restricted model is FALSE but unrestricted is TRUE

help(waldtest)
??waldtest

waldtest(model_b, model_a) # Wald test
# W = 1.25
# under H0: W ~ chisq(df=2)
# p-value = 0.5342
# alpha = 0.01
# p-value > alpha, hence, H0 is not rejected


# * predictions, residuals...
d_new = tibble(carat = c(2, 0.1), x = c(1, 0.1), y = c(2, 0.2), 
               z = c(3, 0.3))

# out of sample predictions
predict(model_a, newdata = d_new) # prediction of LHS: log(price)
exp(predict(model_a, newdata = d_new)) # prediction of price


y_hat = fitted(model_a)  # in-sample predictions
resids = log(d['price']) - y_hat


# * group operations

unique(d['cut'])

# group the dataset on variable 'cut'
# for each diamond calculate the difference between the price and 
# the average price in the group

# without groups
dd = mutate(d, delta_price = price - mean(price))
glimpse(dd)

# with groups 
dd_group = group_by(d, cut) %>% 
  mutate(delta_price = price - mean(price)) 
glimpse(dd_group)


# what is this %>%?

cos(sin(5)) # Euler's idea 
5 %>% sin() %>% cos() # Natural language


dd_group_bis = mutate(group_by(d, cut), # Euler's style
                  delta_price = price - mean(price))

dd_group = group_by(d, cut) %>%  # Natural order of functions
  mutate(delta_price = price - mean(price)) 

head(dd_group_bis)
head(dd_group)


final = group_by(d, cut) %>%  # Natural order of functions
  mutate(delta_price = price - mean(price)) %>%
  filter(delta_price > 1000)

final_bis = filter(mutate(group_by(d, cut), 
                      delta_price = price - mean(price)),
                      delta_price > 1000)


5 %>% cos() %>% log()
log(cos(5))
