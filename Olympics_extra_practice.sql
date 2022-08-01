/*Create a table that lists all country IDs for countries that competed in both the summer and winter Olympics. 78 countries*/

SELECT DISTINCT country_id
FROM summer_games INNER JOIN winter_games USING(country_id)
--GROUP BY country_id

/*Create a table that lists all country IDs for countries that competed in both the summer or winter Olympics. 203 countries*/

SELECT DISTINCT country_id
FROM summer_games FULL JOIN winter_games USING(country_id)
--GROUP BY country_id

/*2a) For each country give the average height and average weight (and age) of their athletes.*/

WITH combined_games as    
    (SELECT *
    FROM summer_games
    UNION
    SELECT *
    FROM winter_games)
SELECT country, AVG(weight)::integer as avg_weight, AVG(height)::integer as avg_height, AVG(age)::integer as avg_age
FROM athletes LEFT JOIN combined_games ON athletes.id = combined_games.athlete_id
              LEFT JOIN countries ON combined_games.country_id = countries.id
GROUP BY country
ORDER BY avg_age DESC

/*For each country give the average height and average weight of their male athletes who won a gold medal.*/
WITH combined_games as 
    (SELECT *
    FROM summer_games
    UNION
    SELECT *
    FROM winter_games)
SELECT country, AVG(height), AVG(weight)
FROM combined_games 
    LEFT JOIN athletes ON combined_games.athlete_id = athletes.id
    LEFT JOIN countries ON countries.id = combined_games.country_id
WHERE gender = 'M' AND gold = 1
GROUP BY country

/*3) Provide a list of athletes who won a gold medal and are shorter than the average Olympic athlete.*/

WITH combined_games as 
    (SELECT *
    FROM summer_games
    UNION
    SELECT *
    FROM winter_games)
SELECT *
FROM combined_games 
    LEFT JOIN athletes ON combined_games.athlete_id = athletes.id
WHERE gold = 1 AND height < (SELECT AVG(height) FROM athletes)

/*4) Provide the total number of medals won for each country in the summer Olympics whose GDP is greater than average 
GDP of countries with at least 1 Nobel Prize winner*/
SELECT country, (SUM(COALESCE(gold,0)) + SUM(COALESCE(silver,0)) + SUM(COALESCE(bronze,0)))
FROM summer_games INNER JOIN countries ON summer_games.country_id = countries.id
WHERE country_id IN						
	(SELECT country_id
	FROM country_stats
	WHERE gdp >					
		(SELECT AVG(GDP)
		FROM country_stats
		WHERE country_id IN (SELECT country_id
					 FROM country_stats
		             GROUP BY country_id
		             HAVING SUM(nobel_prize_winners) > 0))
	GROUP BY country_id)
GROUP BY country

/*) Create a column named ‘participation_level’ that labels countries by the number of unique events they competed in 
between the summer and winter games.  
For less than 10 the rating should be ‘low’ 
for 10-19 the rating should be ‘medium’ 
for 20+ the rating should be ‘high’. */

SELECT country_id, COUNT(DISTINCT event),
        CASE WHEN COUNT(DISTINCT event) < 10 THEN 'low'
             WHEN COUNT (DISTINCT event) < 20 THEN 'medium'
             WHEN COUNT (DISTINCT event) >= 20 THEN 'high' END AS participation_level
FROM summer_games
GROUP BY country_id
ORDER BY country_id