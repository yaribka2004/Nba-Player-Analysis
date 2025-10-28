-- Rank players in each season by points, rebounds, assists per game

-- Find top scorer (highest pts) for each season
WITH season_pts_rank AS (
	SELECT 
		season,
		player_name,
		team_abbreviation,
		pts,
		reb,
		ast,
		ts_pct,
		ROW_NUMBER() OVER (PARTITION BY season ORDER BY pts DESC) AS rank_pts
	FROM 
		nba_players_clean
)

SELECT 
	season,
	player_name,
	team_abbreviation,
	pts
FROM
	season_pts_rank
WHERE 
	rank_pts = 1;

-- Find top rebounder (highest reb) for each season
WITH season_reb_rank AS (
	SELECT 
		season,
		player_name,
		team_abbreviation,
		pts,
		reb,
		ast,
		ts_pct,
        ROW_NUMBER() OVER (PARTITION BY season ORDER BY reb DESC) AS rank_reb
	FROM 
		nba_players_clean
)

SELECT 
	season,
	player_name,
	team_abbreviation,
	reb
FROM 
	season_reb_rank
WHERE 
	rank_reb = 1;

-- Find top playmaker (highest ast) for each season
WITH season_ast_rank AS (
	SELECT 
		season,
		player_name,
		team_abbreviation,
		ast,
        ROW_NUMBER() OVER (PARTITION BY season ORDER BY ast DESC) AS rank_ast
	FROM 
		nba_players_clean
)

SELECT 
	season,
	player_name,
	team_abbreviation,
	ast
FROM 
	season_ast_rank
WHERE 
	rank_ast = 1;
    
-- Compare efficiency stats (TS% vs usage%) - do volume scorers sacrifice efficiency?
/*
	Method: Calculates Pearson correlation between TS% and usage% for every season.
    r ≈ 1 -> The more usage, the higher the efficiency
    r ≈ 0 -> Usage% and TS% are independent of each other
    r ≈ -1 -> The higher the usage, the lower the efficiency 
*/

-- Comparison for each season
WITH average_usg_ts AS (
	SELECT 
		season,
		usg_pct,
		ts_pct,
		AVG(usg_pct) OVER (PARTITION BY season) AS avg_usg,
		AVG(ts_pct) OVER (PARTITION BY season) AS avg_ts
	FROM 
		nba_players_clean
)
SELECT 
	season,
    ROUND(
        SUM((usg_pct - avg_usg) * (ts_pct - avg_ts)) /
        (SQRT(SUM(POWER(usg_pct - avg_usg, 2))) * 
         SQRT(SUM(POWER(ts_pct - avg_ts, 2)))),
        3) AS The_Pearson_coefficient
FROM
	average_usg_ts
GROUP BY 
	season;

-- Comparison for each player
WITH average_usg_ts AS (
	SELECT 
		player_name,
		usg_pct,
		ts_pct,
		AVG(usg_pct) OVER (PARTITION BY player_name) AS avg_usg,
		AVG(ts_pct) OVER (PARTITION BY player_name) AS avg_ts
	FROM 
		nba_players_clean
)
SELECT 
	player_name,
    ROUND(
        SUM((usg_pct - avg_usg) * (ts_pct - avg_ts)) /
        (SQRT(SUM(POWER(usg_pct - avg_usg, 2))) * 
         SQRT(SUM(POWER(ts_pct - avg_ts, 2)))),
        3) AS The_Pearson_coefficient
FROM
	average_usg_ts
GROUP BY 
	player_name
HAVING 
	COUNT(*) > 2;

-- Identify most improved players across seasons (biggest jump in points/rebounds/assists)

-- Most improved players by points
WITH players_lag AS (
	SELECT
		player_name,
		season,
		pts,
		LAG(pts) OVER(PARTITION BY player_name ORDER BY season) AS prev_pts
	FROM 
		nba_players_clean
)

SELECT 
	player_name,
	season,
    ROUND(pts - prev_pts, 3) AS pts_improved
FROM 
	players_lag
WHERE 
	prev_pts IS NOT NULL
ORDER BY 
	pts_improved DESC
LIMIT 25;

-- Most improved players by rebounds
WITH players_lag AS (
	SELECT
		player_name,
		season,
		reb,
		LAG(reb) OVER(PARTITION BY player_name ORDER BY season) AS prev_reb
	FROM 
		nba_players_clean
)

SELECT 
	player_name,
	season,
    ROUND(reb - prev_reb, 3) AS reb_improved
FROM 
	players_lag
WHERE 
	prev_reb IS NOT NULL
ORDER BY 
	reb_improved DESC
LIMIT 25;

---- Most improved players by assists
WITH players_lag AS (
	SELECT
		player_name,
		season,
		ast,
		LAG(ast) OVER(PARTITION BY player_name ORDER BY season) AS prev_ast
	FROM 
		nba_players_clean
)

SELECT 
	player_name,
	season,
    ROUND(ast - prev_ast, 3) AS ast_improved
FROM 
	players_lag
WHERE 
	prev_ast IS NOT NULL
ORDER BY 
	ast_improved DESC
LIMIT 25;