-- Use a weighted index (e.g., 40% points, 30% rebounds/assists, 30% efficiency) to find an MVP for a given season.
WITH player_mvp_score AS (
    SELECT 
		player_name,
		season,
		team_abbreviation,
		pts,
		reb,
		ast,
		ts_pct,
		ROUND(
			(pts * 0.4)
			+ (reb * 0.15)
            + (ast * 0.15)
			+ (net_rating * 0.2)
			+ (ts_pct * 100 * 0.1), 2) AS mvp_score
	FROM
		nba_players_clean
	WHERE 
		gp >= 60
)

SELECT 
	season,
    player_name,
    team_abbreviation,
    mvp_score
FROM (
	SELECT
		*,
        ROW_NUMBER() OVER (PARTITION BY season ORDER BY mvp_score DESC) as rn_mvp
	FROM
		player_mvp_score
	) rank_t
WHERE 
	rn_mvp = 1;

-- Build your dream starting 5 (PG, SG, SF, PF, C) using stats across all seasons.


WITH player_height_avg AS (
	-- Calculate the average height for each player across all seasons
    SELECT 
        player_name,
        ROUND(AVG(player_height), 1) AS avg_height
    FROM 
        nba_players_clean
    GROUP BY 
        player_name
),

player_position AS (
    -- Assign position based on average height
    SELECT 
        p.*,
        CASE
            WHEN h.avg_height >= 180 AND h.avg_height < 193 THEN 'PG'
            WHEN h.avg_height >= 193 AND h.avg_height < 200 THEN 'SG'
            WHEN h.avg_height >= 200 AND h.avg_height < 206 THEN 'SF'
            WHEN h.avg_height >= 206 AND h.avg_height < 213 THEN 'PF'
            WHEN h.avg_height >= 213 THEN 'C'
            ELSE NULL
        END AS position
    FROM 
        nba_players_clean p
    INNER JOIN 
        player_height_avg h 
        ON p.player_name = h.player_name
),
player_stats AS (
    SELECT
        player_name,
        position,
        ROUND(AVG(pts), 2) AS avg_pts,
        ROUND(AVG(reb), 2) AS avg_reb,
        ROUND(AVG(ast), 2) AS avg_ast,
        ROUND(AVG(ts_pct), 2) AS avg_ts_pct,
        ROUND(AVG(net_rating), 2) AS avg_net_rating,
        SUM(gp) AS total_gp 
    FROM 
        player_position 
    WHERE 
        gp >= 60
    GROUP BY 
        player_name,
        position
    HAVING 
        COUNT(DISTINCT season) >= 4
),
player_mvp_score AS (
    SELECT 
        *,
        (avg_pts * 0.4)
        + (avg_reb * 0.15)
		+ (avg_ast * 0.15)
        + (avg_net_rating * 0.2)
        + (avg_ts_pct * 100 * 0.1) AS score
    FROM
        player_stats
),
rn_by_position AS (
    SELECT 
        *,
        ROW_NUMBER() OVER (PARTITION BY position ORDER BY score DESC) AS rn
    FROM 
        player_mvp_score
)

SELECT 
    position,
    player_name,
    ROUND(score, 2) AS score,
    avg_pts,
    avg_reb,
    avg_ast,
    avg_net_rating,
    total_gp
FROM 
    rn_by_position
WHERE 
    rn = 1
    AND position IS NOT NULL
ORDER BY
    CASE position
        WHEN 'PG' THEN 1
        WHEN 'SG' THEN 2
        WHEN 'SF' THEN 3
        WHEN 'PF' THEN 4
        WHEN 'C' THEN 5
    END;

-- Bonus: Compare your MVP pick with the actual NBA MVP that season

WITH player_mvp_score AS (
	SELECT
		player_name,
		season,
		team_abbreviation,
		pts,
		reb,
		ast,
		ts_pct,
		ROUND(
			(pts * 0.4)
			+ (reb * 0.15)
            + (ast * 0.15)
			+ (net_rating * 0.2)
			+ (ts_pct * 100 * 0.1), 2) AS mvp_score
	FROM 
		nba_players_clean
	WHERE 
		gp >= 60
),
my_mvp_list AS (
	SELECT
		season,
		player_name AS my_mvp,
		team_abbreviation,
		mvp_score
	FROM (
		SELECT 
			*,
			ROW_NUMBER() OVER (PARTITION BY season ORDER BY mvp_score DESC) AS rn_mvp
		FROM 
			player_mvp_score
	) rank_mvp
	WHERE
		rn_mvp = 1
),
actual_mvp_list AS (

	SELECT *
	FROM (
		VALUES 
		ROW('1996-97', 'Karl Malone'),
		ROW('1997-98', 'Michael Jordan'), 
		ROW('1998-99', 'Karl Malone'), 
		ROW('1999-00', 'Shaquille O''Neal'), 
		ROW('2000-01', 'Allen Iverson'), 
		ROW('2001-02', 'Tim Duncan'), 
		ROW('2002-03', 'Tim Duncan'), 
		ROW('2003-04', 'Kevin Garnett'), 
		ROW('2004-05', 'Steve Nash'), 
		ROW('2005-06', 'Steve Nash'), 
		ROW('2006-07', 'Dirk Nowitzki'), 
		ROW('2007-08', 'Kobe Bryant'), 
		ROW('2008-09', 'LeBron James'), 
		ROW('2009-10', 'LeBron James'), 
		ROW('2010-11', 'Derrick Rose'), 
		ROW('2011-12', 'LeBron James'), 
		ROW('2012-13', 'LeBron James'), 
		ROW('2013-14', 'Kevin Durant'), 
		ROW('2014-15', 'Stephen Curry'), 
		ROW('2015-16', 'Stephen Curry'), 
		ROW('2016-17', 'Russell Westbrook'), 
		ROW('2017-18', 'James Harden'), 
		ROW('2018-19', 'Giannis Antetokounmpo'), 
		ROW('2019-20', 'Giannis Antetokounmpo'), 
		ROW('2020-21', 'Nikola Jokic'), 
		ROW('2021-22', 'Nikola Jokic'), 
		ROW('2022-23', 'Joel Embiid')
		) AS t(season, actual_mvp)
)

SELECT 
	t1.season,
    my_mvp,
    actual_mvp,
    CASE
		WHEN t1.my_mvp = t2.actual_mvp THEN '+' -- Match
        ELSE '-' -- No match 
        END AS comparison
FROM
	my_mvp_list t1
LEFT JOIN
	actual_mvp_list t2
    ON t1.season = t2.season;



    

