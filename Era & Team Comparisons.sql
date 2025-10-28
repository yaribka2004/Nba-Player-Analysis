-- Compare average player size (height/weight) between 1990s, 2000s, 2010s, and 2020s.

WITH decades AS (
    SELECT 
		CASE
			WHEN LEFT(season, 4) BETWEEN 1990 AND 1999 THEN '1990s'
			WHEN LEFT(season, 4) BETWEEN 2000 AND 2009 THEN '2000s'
			WHEN LEFT(season, 4) BETWEEN 2010 AND 2019 THEN '2010s'
			WHEN LEFT(season, 4) BETWEEN 2020 AND 2029 THEN '2020s'
		END AS decade,
		player_height,
		player_weight
	FROM 
		nba_players_clean
)

SELECT 
	decade,
    ROUND(AVG(player_height), 2) AS avg_height,
    ROUND(AVG(player_weight), 2) AS avg_weight
FROM
	decades 
GROUP BY 
	decade;

-- Identify which teams consistently produce top-performing players.

-- TOP 25 teams by frequency of players appearing among top 25 scorers each season 
WITH pts_rank_players AS (
	SELECT
		player_name,
		team_abbreviation,
		season,
		pts,
		ROW_NUMBER() OVER(PARTITION BY season ORDER BY pts DESC) AS rank_pts
	FROM 
		nba_players_clean
)

-- How many times a team's players appear in the TOP 25
SELECT 
    team_abbreviation,
    COUNT(*) AS TOP_25_appearances 
FROM 
    pts_rank_players
WHERE 
    rank_pts <= 25
GROUP BY 
    team_abbreviation
ORDER BY 
    TOP_25_appearances DESC;

-- Look at rookies vs veterans - how do their contributions differ?

-- How much rookies and veterans contribute on average in points, rebounds, and assists
WITH players_first_season AS (
	SELECT 
		player_name,
		MIN(SUBSTRING_INDEX(season, '-', 1)) AS first_season
	FROM
		nba_players_clean
	GROUP BY 
		player_name
),
type AS (
	SELECT 
		t1.player_name,
		CASE 
			WHEN SUBSTRING_INDEX(t1.season, '-', 1) = first_season THEN 'Rookie'
			ELSE 'Veteran'
		END AS career_stage,
		pts,
		reb,
		ast
	FROM 
		nba_players_clean t1
	INNER JOIN 
		players_first_season t2 
		ON t1.player_name = t2.player_name
),
players_avg AS (
	SELECT 
		player_name,
		career_stage,
		AVG(pts) AS avg_players_pts,
		AVG(reb) AS avg_players_reb,
		AVG(ast) AS avg_players_ast
	FROM 
		type 
	GROUP BY 
		player_name,
		career_stage
)

SELECT
	career_stage,
    ROUND(AVG(avg_players_pts), 2) AS avg_pts,
    ROUND(AVG(avg_players_reb), 2) AS avg_reb,
    ROUND(AVG(avg_players_ast), 2) AS avg_ast,
    COUNT(*) AS players_count
FROM 
	players_avg
GROUP BY 
	career_stage;
    
