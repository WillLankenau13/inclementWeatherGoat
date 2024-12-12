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
d_qb_games <- read_csv("~/R Stuff/inclementWeatherGoat/qb_games.csv")
schedule <- read_csv("~/R Stuff/inclementWeatherGoat/tidy_schedule.csv")

#
qb_games <- d_qb_games %>% 
  filter(Year > 1999) %>% 
  filter(Season == "Regular Season")

#NA values
qb_games[qb_games == "--"] <- NA

#filter passes attempted
qb_games <- qb_games %>% 
  filter(`Passes Attempted` > 0)

#date
qb_games <- qb_games %>% 
  mutate(date = paste(`Game Date`, Year, sep = " ")) %>% 
  mutate(date = parse_datetime(date, "%m/%d %Y")) %>% 
  mutate(Opponent = ifelse(Opponent == "JAC", "JAX", Opponent))

#filter home games
home_qb <- qb_games %>% 
  filter(`Home or Away` == "Home") %>% 
  left_join(schedule, by = c("Opponent" = "AwayID", "date")) %>% 
  rename("AwayID" = "Opponent")

#filter away games
away_qb <- qb_games %>% 
  filter(`Home or Away` == "Away") %>% 
  left_join(schedule, by = c("Opponent" = "HomeID", "date")) %>% 
  rename("HomeID" = "Opponent")

#rbind
qb_stats <- rbind(home_qb, away_qb) %>% 
  rename("HA" = "Home or Away")
  
#write_csv
write_csv(qb_stats, "~/R Stuff/inclementWeatherGoat/qb_stats.csv")




