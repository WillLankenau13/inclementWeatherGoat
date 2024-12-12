

scores <- full_join(away_weather_ratings, home_weather_ratings, by = c("Name")) %>% 
  full_join(weather_ratings, by = c("Name")) %>% 
  select(Name, overall_score.x, overall_score.y, overall_score, incl_c.x, incl_c.y, incl_c) %>% 
  mutate(incl_c.x = ifelse(is.na(incl_c.x), incl_c - incl_c.y, incl_c.x)) %>% 
  mutate(incl_c.y = ifelse(is.na(incl_c.y), incl_c - incl_c.x, incl_c.y)) %>% 
  mutate(percent = incl_c.y/incl_c)

ggplot(scores, aes(percent, overall_score), position = "jitter") +
  geom_jitter() 

home_vs_ovr <- scores %>% 
  select(Name, overall_score.y, overall_score) %>% 
  filter(!is.na(overall_score.y))

away_vs_ovr <- scores %>% 
  select(Name, overall_score.x, overall_score) %>% 
  filter(!is.na(overall_score.x))

home_vs_away <- scores %>% 
  select(Name, overall_score.x, overall_score.y) %>% 
  filter(!is.na(overall_score.y)) %>% 
  filter(!is.na(overall_score.x))


ggplot(home_vs_ovr, aes(overall_score.y, overall_score), position = "jitter") +
  geom_jitter() +
  geom_abline(slope = 1, intercept = 0)

ggplot(away_vs_ovr, aes(overall_score.x, overall_score), position = "jitter") +
  geom_jitter() +
  geom_abline(slope = 1, intercept = 0)
  
ggplot(home_vs_away, aes(overall_score.x, overall_score.y), position = "jitter") +
  geom_jitter() +
  geom_abline(slope = 1, intercept = 0)
