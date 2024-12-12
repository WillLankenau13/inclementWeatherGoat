library("ggplot2")
library("tidyverse")
library("lubridate")
library("incidence")
library("stringr")
library("janitor")
library("readr")
library("dplyr")
library("modelr")
library("leaps")
library("ggrepel")


#Import data
data <- read_csv("~/R Stuff/inclementWeatherGoat/for_analysis.csv") %>% 
  rename("pr" = "Passer Rating") %>% 
  select(Name, date, HomeID, AwayID, HA, Outcome, Score, pr, date, conditionScore:weatherScore, StadiumName)

ha <- c("Home", "Away")

#home_weather_ratings <- weather_ratings

rodgers <- data %>% 
  filter(Name == "Harrington, Joey")

rodgers_c <- data %>% 
  mutate(rodgers = ifelse(Name == "Rodgers, Aaron", TRUE, FALSE)) %>% 
  filter(weatherScore > 6)

#scatterplot
ggplot(rodgers, aes(weatherScore, pr), position = "jitter") +
  geom_jitter()

ggplot(rodgers_c, aes(weatherScore, pr), position = "jitter") +
  geom_jitter(aes(color = rodgers)) +
  xlim(6, 25) +
  ylim(0, 160)
  
#model
mod <- lm(pr ~ weatherScore, data = data)
summary(mod)

#get residuals
data$resid <- mod$resid

#Add results
data <- data %>% 
  mutate(result = ifelse(Outcome == "W", 1, ifelse(Outcome == "L", 0, 0.5)))

#filter ha
data <- data %>% 
  filter(HA %in% ha)

#filter
inclement_weather <- data %>% 
  filter(weatherScore > 6)
good_weather <- data %>% 
  filter(weatherScore <= 6)

#average score per group
inclement_scores <- inclement_weather %>% 
  group_by(Name) %>% 
  summarize(absolute_rating = mean(resid),
            abs_actual = mean(pr),
            incl_c = n()) %>% 
  filter(incl_c > 3)
good_scores <- good_weather %>% 
  group_by(Name) %>% 
  summarize(g_mean = mean(resid),
            g_abs_actual = mean(pr),
            g_count = n())

#difference rating
score <- full_join(inclement_scores, good_scores, by = c("Name")) %>% 
  mutate(difference_rating = absolute_rating - g_mean,
         act_difference_rating = abs_actual - g_abs_actual) %>% 
  filter(!is.na(incl_c))

#Scale weather
data <- data %>% 
  mutate(mul_score = weatherScore*resid)

full_weather_ratings <- data %>% 
  group_by(Name) %>% 
  summarize(sum_mul_score = sum(mul_score),
            tot_weatherScore = sum(weatherScore),
            count = n()) %>% 
  mutate(scaled_rating = sum_mul_score/tot_weatherScore) %>% 
  full_join(score, by = c("Name")) %>%
  mutate(dif_scaled = scaled_rating - g_mean) %>% 
  filter(incl_c > 3)

#Select
weather_ratings <- full_weather_ratings %>% 
  select(Name, absolute_rating, difference_rating, scaled_rating, dif_scaled, g_mean, incl_c, count, abs_actual, g_abs_actual, act_difference_rating)

#Standardize
weather_ratings['std_abs'] <- scale(weather_ratings['absolute_rating']) 
weather_ratings['std_dif'] <- scale(weather_ratings['difference_rating']) 
weather_ratings['std_scl'] <- scale(weather_ratings['scaled_rating']) 
weather_ratings['std_dif_scl'] <- scale(weather_ratings['dif_scaled']) 


#stadiums
stadiums <- data %>% 
  filter(weatherScore > 6) %>% 
  group_by(StadiumName) %>% 
  summarize(count = n(),
            mean = mean(weatherScore))

inclement_stadiums = c("Lambeau Field", "New Era Field", "Soldier Field", "FirstEnergy Stadium", "Giants Stadium", "Gillette Stadium")

inclement_data <- data %>% 
  mutate(Stadium = ifelse(StadiumName %in% inclement_stadiums, StadiumName, "All Other")) %>% 
  filter(weatherScore > 6)

#win loss percent
wl_inclement <- inclement_weather %>% 
  group_by(Name) %>% 
  summarize(incl_games = n(),
            incl_wins = sum(result)) %>% 
  mutate(incl_w_pct = incl_wins/incl_games) %>% 
  filter(incl_games > 3)

wl_good <- good_weather %>% 
  group_by(Name) %>% 
  summarize(g_games = n(),
            g_wins = sum(result)) %>% 
  mutate(g_w_pct = g_wins/g_games) %>% 
  filter(g_games > 3)

wl <- inner_join(wl_good, wl_inclement, by = c("Name")) %>% 
  mutate(dif_win_pct = incl_w_pct - g_w_pct)

#overall score
weather_ratings <- weather_ratings %>% 
  full_join(wl, by = c("Name")) %>% 
  mutate(overall_score = (std_abs + std_dif + std_scl + std_dif_scl)/4) %>% 
  select(-c("g_wins", "incl_wins"))

#flynn
flynn <- data %>% 
  filter(Name == "Flynn, Matt")

#important
weather_ratings <- weather_ratings %>% 
  mutate(important = ifelse(overall_score > 1, "Good", "mid"),
         important = ifelse(overall_score < -1.6 & important == "mid", "Bad", important))

####graphing####

#stadiums and weather histogram
ggplot(inclement_data, aes(x=weatherScore,fill=Stadium)) + 
  geom_histogram(binwidth=1) + 
  ggtitle("Histogram Of Weather Scores with Stadium") +
  labs(x = "Weather Scores", y = "Count")

#all passer ratings
ggplot(data, aes(weatherScore, pr), position = "jitter") +
  geom_jitter() +
  xlim(0, 25) +
  ylim(0, 160) +
  geom_abline(slope = mod$coefficients[2], intercept = mod$coefficients[1], color = 'black') + 
  ggtitle("Scatterplot of Passer Rating vs Weather Score") +
  labs(x = "Weather Score", y = "Passer Rating", subtitle = "With a Trendline")

#good weather vs inclement - act - games size - scatterplot
ggplot(weather_ratings, aes(g_abs_actual, abs_actual, size = incl_c, color = important), position = "jitter") +
  scale_color_manual(values=c('red','blue','black')) +
  geom_jitter() +
  xlim(30, 120) +
  ylim(30, 120) +
  geom_text_repel(data=subset(weather_ratings, overall_score > 1 | overall_score < -1.6),
            aes(g_abs_actual, abs_actual, label=Name, size = 10)) +
  geom_abline(slope = 1, intercept = 0) + 
  ggtitle("Scatterplot of PRs in Inclement vs Non-Inclement") +
  labs(x = "Non-Inclement Average PR", y = "Inclement Average PR", subtitle = "With a Line Slope = 1", size = "Inclement Game Count", color = "Noteworthy")

#good weather vs inclement - resid - games size - scatterplot
ggplot(weather_ratings, aes(g_mean, absolute_rating, size = incl_c, color = important), position = "jitter") +
  scale_color_manual(values=c('red','blue','black')) +
  geom_jitter() +
  xlim(-30, 30) +
  ylim(-40, 40) +
  geom_text_repel(data=subset(weather_ratings, overall_score > 1 | overall_score < -1.6),
            aes(g_mean, absolute_rating, label=Name, size = 10)) +
  geom_abline(slope = 1, intercept = 0) + 
  ggtitle("Scatterplot of PR residuals in Inclement vs Non-Inclement") +
  labs(x = "Non-Inclement Average Residual", y = "Inclement Average Residual", subtitle = "With a Line Slope = 1", size = "Inclement Game Count", color = "Noteworthy")

#incl win percent vs overall rating
ggplot(weather_ratings, aes(overall_score, incl_w_pct, size = incl_c, color = important), position = "jitter") +
  scale_color_manual(values=c('red','blue','black')) +
  geom_jitter()+
  xlim(-3, 3) +
  ylim(0, 1) +
  geom_text_repel(data=subset(weather_ratings, overall_score > 1 | overall_score < -1.6),
            aes(overall_score, incl_w_pct, label=Name, size = 10)) + 
  ggtitle("Scatterplot of Inclement Weather Win Percent vs Overall Score") +
  labs(x = "Overall Score", y = "Inclement Weather Win Percent", size = "Inclement Game Count", color = "Noteworthy")

#difference inclement win percent vs overall rating
ggplot(weather_ratings, aes(overall_score, dif_win_pct, size = incl_c, color = important), position = "jitter") +
  scale_color_manual(values=c('red','blue','black')) +
  geom_jitter()+
  xlim(-3, 3) +
  ylim(-0.6, 0.6) +
  geom_text_repel(data=subset(weather_ratings, overall_score > 1 | overall_score < -1.6),
            aes(overall_score, dif_win_pct, label=Name, size = 10)) + 
  ggtitle("Scatterplot of Difference in Win Percent vs Overall Score") +
  labs(x = "Overall Score", y = "Difference in Win Percent", subtitle = "Difference is Inclement Win Percent - Non-Inclement Win Percent", size = "Inclement Game Count", color = "Noteworthy")


####write csv####
write_csv(weather_ratings, "~/R Stuff/inclementWeatherGoat/results.csv")
write_csv(stadiums, "~/R Stuff/inclementWeatherGoat/inclement_by_stadium.csv")
