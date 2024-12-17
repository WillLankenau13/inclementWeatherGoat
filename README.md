# Introduction

This repository contains the code for a project where we found the NFL Inclement Weather Goat: the NFL quarterback who has performed the best in inclement weather. This was a part of a small group project for a sports statistics class in my senior year of high school. Our group came up with the methodology, but I wrote the code in this repository. 


# Data

Weather data was downloaded from [this](https://github.com/ThompsonJamesBliss/WeatherData/tree/master) repository.
Quarterback ratings were downloaded from [Stathead](Stathead.com).


# Methodology

### Quarterback Rating
We used a quarterbacks passer rating to determine how well they played in a given game. 

### Weather Rating
We gave each game a weather rating, based on the amount of precipitation, temperature, wind, and whether it was snowing. Games considered "inclement weather games" had weather ratings greater 6. The ratings were determined as follows. 
- Condition Score: 6 if light (rain or snow), 12 if moderate, 18 if heavy
- Temperature Score: 14 - (temperature - 12)/2; 14 if temperature below 12, 0 if above 40
- Wind Score: (windSpeed - 12)/2; 7 if above 26, 0 if below 12
- Snow Score: 1 if light snow, 2 if moderate snow, 3 if heavy snow, 0 otherwise

The weather rating is the sum of the 4 above scores. So, a game with moderate snow, temperature of 16 degrees Fahrenheit, and 14 mph winds would have a weather score of (12 + 12 + 1 + 2) = 27. 

### Inclement Performance Rating
A quarterback's Inclement Performance Rating (IPR) is the average of 4 standardized ratings:
- Absolute Rating: How well the QB played in inclement weather games
- Difference Rating: How well the QB played in inclement weather games compared to how well they played in non-inclement games
- Scaled Rating: How well the QB played in inclement weather games, weighing games with higher inclement weather ratings more
- Difference Scaled Rating: How well the QB played in inclement weather games compared to how well they played in non-inclement games, weighing games with higher inclement weather ratings more

Each rating takes into account the average passer rating for the inclement weather score. 

We ran a linear regression of passer rating against inclement weather score to get a predicted passer rating for each inclement weather score. 

So, to get a quarterback's Absolute Rating, predict the passer ratings for each game using the abore regression. Then, calculate the residuals of their passer ratings for inclement weather games and take the mean. 

Each rating is calculated with the residuals, instead of the raw passer rating. 

After calculating each rating, standardize them and take the average to get a IPR for each quarterback. 

# Findings

We found that Brock Osweiler is the quarterback who has performed the best in inclement weather with an IPR of 1.74. Matt Flynn was second with 1.56 while Aaron Rodgers was third with 1.37. On the flip side, the quarterbacks who have perfomed the worst in inclement weather are Jay Fiedler, Joey Harrington, and Kirk Cousins, with IPRs of -2.02, -1.88, and -1.81 respectively. 

It should be noted that although we only considered players with 4 or more inclement weather games, 4 games is still quite a small sample size. Out of the 36 quarterbacks who had 4 or more inclement weather games, only 9 had more than 10. Of the 3 best and 3 worst quarterbacks listed above, all but 1 had 4-6 inclement weather games; Rodgers had 18 inclement weather games. So, the ratings for 5 of the 6 players listed above could reasonably be attributed to their small sammple size rather than performing especially bad in inclement weather. 


# Info

Date Created: April 19 2023
