library("tidyverse")


#Import Data
d_schedule <- read_csv("~/R Stuff/inclementWeatherGoat/Data/NFLSchedule.csv")
team_code <- read_csv("~/R Stuff/inclementWeatherGoat/Data/team_code.csv")

colnames(team_code) <- c("Team", "ID")

#schedule
schedule <- d_schedule %>% 
  filter(Year > 1999)

#date
sche <- schedule %>% 
  mutate(date = paste(Date, Year, sep = " ")) %>% 
  mutate(date = parse_datetime(date, "%B %d %Y")) %>% 
  select(HomeTeam, AwayTeam, date)

schedule <- sche %>% 
  left_join(team_code, by = c("HomeTeam" = "Team")) %>% 
  rename("HomeID" = "ID") %>% 
  left_join(team_code, by = c("AwayTeam" = "Team")) %>% 
  rename("AwayID" = "ID")


#Write Csv
write_csv(schedule, "~/R Stuff/inclementWeatherGoat/Data/tidy_schedule.csv")



