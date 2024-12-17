library("tidyverse")


#Import data
d_weather_data <- read_csv("~/R Stuff/inclementWeatherGoat/Data/weather_data.csv") 
d_weather_games <- read_csv("~/R Stuff/inclementWeatherGoat/Data/weather_games.csv")
d_stadium_data <- read_csv("~/R Stuff/inclementWeatherGoat/Data/stadium_data.csv")


#Weather Scores
weather_data <- d_weather_data %>% 
  mutate(conditionScore = ifelse(EstimatedCondition == "Clear", 0, NA),
         conditionScore = ifelse(EstimatedCondition == "Light Rain", 6, conditionScore),
         conditionScore = ifelse(EstimatedCondition == "Light Snow", 6, conditionScore),
         conditionScore = ifelse(EstimatedCondition == "Moderate Rain", 12, conditionScore),
         conditionScore = ifelse(EstimatedCondition == "Moderate Snow", 12, conditionScore),
         conditionScore = ifelse(EstimatedCondition == "Heavy Rain", 18, conditionScore),
         conditionScore = ifelse(EstimatedCondition == "Heavy Snow", 18, conditionScore),
         conditionScore = ifelse(is.na(EstimatedCondition), 0, conditionScore)) %>% 
  mutate(tempScore = ifelse(Temperature <= 12, 14, NA),
         tempScore = ifelse(Temperature > 40, 0, tempScore),
         tempScore = ifelse(is.na(tempScore), 14 - (Temperature - 12)/2, tempScore)) %>% 
  mutate(windScore = ifelse(WindSpeed <= 12, 0, NA),
         windScore = ifelse(WindSpeed > 26, 7, windScore),
         windScore = ifelse(is.na(windScore), (WindSpeed - 12)/2, windScore)) %>% 
  mutate(snowScore = ifelse(EstimatedCondition == "Heavy Snow", 3, NA),
         snowScore = ifelse(EstimatedCondition == "Moderate Snow", 2, snowScore),
         snowScore = ifelse(EstimatedCondition == "Light Snow", 1, snowScore),
         snowScore = ifelse(is.na(snowScore), 0, snowScore)) %>% 
  mutate(weather_score = conditionScore + tempScore + windScore + snowScore) %>% 
  filter(!is.na(weather_score))

#Group by game and take average
g_weather_data <- weather_data %>% 
  group_by(game_id) %>% 
  summarize(conditionScore = mean(conditionScore),
            tempScore = mean(tempScore),
            windScore = mean(windScore),
            snowScore = mean(snowScore),
            weatherScore = mean(weather_score))

#Weather Score histogram
ggplot(data = g_weather_data) +
  geom_histogram(mapping = aes(x = weatherScore))

#Combine with games
combined <- inner_join(g_weather_data, d_weather_games, by = c("game_id"))

#Domes
combined <- combined %>% 
  left_join(d_stadium_data, by = c("StadiumName")) %>% 
  mutate(conditionScore = ifelse(RoofType == "Outdoor", conditionScore, 0),
         tempScore = ifelse(RoofType == "Outdoor", tempScore, 0),
         windScore = ifelse(RoofType == "Outdoor", windScore, 0),
         snowScore = ifelse(RoofType == "Outdoor", snowScore, 0),
         weatherScore = ifelse(RoofType == "Outdoor", weatherScore, 0))

#Get date
combined <- combined %>% 
  mutate(date_time = parse_datetime(TimeStartGame, "%m/%d/%Y %H:%M"),
         date = as.Date(date_time))

#Stadiums
stadiums <- combined %>% 
  distinct(StadiumName)


#write csv
write_csv(stadiums, "~/R Stuff/inclementWeatherGoat/Data/stadium_names.csv")
write_csv(combined, "~/R Stuff/inclementWeatherGoat/Data/tidy_weather.csv")

