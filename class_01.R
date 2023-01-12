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


