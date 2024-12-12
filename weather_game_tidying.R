library("ggplot2")
library("tidyverse")
library("lubridate")
library("incidence")
library("stringr")
library("janitor")
library("readr")
library("dplyr")
library("modelr")
library(leaps)

#Import data
d_tidy_weather <- read_csv("~/R Stuff/inclementWeatherGoat/tidy_weather.csv") 
d_stadiums <- read_csv("~/R Stuff/inclementWeatherGoat/team_stadiums.csv") 
d_qb_stats <- read_csv("~/R Stuff/inclementWeatherGoat/qb_stats.csv") 

#select rows
qb_stats <- d_qb_stats %>% 
  select(Name, date, HomeID, AwayID, HA, Outcome, Score, `Passer Rating`) 

tidy_weather <- d_tidy_weather %>% 
  filter(year(date) < 2017) %>% 
  select(date, StadiumName, conditionScore, tempScore, windScore, snowScore, weatherScore)

#combining
combined <- left_join(tidy_weather, d_stadiums, by = c("StadiumName")) %>% 
  rename("HomeID" = "Team") %>% 
  inner_join(qb_stats, by = c("HomeID", "date"))


write_csv(combined, "~/R Stuff/inclementWeatherGoat/for_analysis.csv")



