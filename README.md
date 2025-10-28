# 🏀 NBA Player Performance Analysis (1996 - 2023) 


## 📘 Project Overview
There is a constant debate among fans in the NBA about who is GOAT. 
Actually, this project will answer this question for someone. I have analyzed 27 seasons and over 12,000 players using MySQL. 
Let's figure it out

## 🎯 Objectives
- Which players lead their seasons in scoring, rebounding, and playmaking - and how efficient are they?
- How do players from different eras (1990s, 2000s, 2010s, 2020s) compare in size, style, and performance?
- Which teams, positions, or player types consistently produce top performers?
- Based on the data, who deserves the MVP crown - and how does your pick compare to the official NBA MVP?

## 🧠 Skills Demonstrated
- Advanced Query Structuring (CTEs): Extensive use of Common Table Expressions to break down complex analytical problems into logical, readable, and modular multi-step queries
- Window Functions: Applied ROW_NUMBER(), LAG(), and AVG() OVER() for ranking, trend, and correlation analysis
- Statistical Modeling: Implemented Pearson correlation and custom weighted indexes (MVP score) directly in SQL
- Data Engineering: Created dynamic groupings with CASE and SUBSTRING_INDEX, including decade and position categorization
- Data Validation: Used in-memory tables (VALUES) and JOIN logic to benchmark model results VS real-world MVPs
- Custom Sorting & Aggregation: Optimized GROUP BY, HAVING, and CASE-based sorting for clarity and accuracy.

## 🔍 Key Analyses  
1) Player Performance Analysis
  - Rank players in each season by points, rebounds, assists per game.
   Identified the top scorer, rebounder, and playmaker for each NBA season.
   Scoring Leaders: From the late ’90s to 2020s, scoring dominance shifted from Michael Jordan and Shaquille O’Neal to Kobe Bryant, Kevin Durant, Stephen Curry, and James Harden. The peak — Harden’s 36.1 PPG (2018–19).
   Rebounding Leaders: Dominated by elite big men — Dennis Rodman, Kevin Garnett, Dwight Howard, and Andre Drummond.
   Playmaking Leaders: Floor generals like Jason Kidd, Steve Nash, Chris Paul, and Russell Westbrook defined their decades, maintaining assist averages above 10 per game.
  - Compare efficiency stats (TS% vs usage%) - do volume scorers sacrifice efficiency?
   I calculated the Pearson Correlation Coefficient (r) to measure the relationship between Usage% and True Shooting%.
   r ≈ 1: High usage → higher efficiency
   r ≈ 0: No clear relationship
   r ≈ –1: High usage → lower efficiency
   For example, Joel Embiid (r = 0.60): A strong positive correlation. In the seasons where Embiid's usage increased, his efficiency also significantly increased. This profile is typical of a transcendent superstar growing into his prime, taking on a massive load and becoming more dominant, not less. LeBron James (r = 0.199): A       weak positive correlation. For LeBron, there's a slight tendency for his efficiency to rise with his usage, but the two are mostly independent. His efficiency remains world-class regardless of the offensive load he is asked to carry in any given season. Michael Jordan (r = -0.072): A near-zero correlation. Jordan's efficiency      and usage had no statistical relationship. He was an absolute machine. His scoring efficiency remained virtually identical whether he was taking a "low" number of shots (for him) or a "high" number.
  - Identify most improved players across seasons (biggest jump in points/rebounds/assists).
   Scoring: Explosive single-season breakouts — MarShon Brooks (2018, +15.6 PPG), Paul George (2016, +14.3 PPG), CJ McCollum (2016, +14.0 PPG), and Stephen Curry (2021, +11.2 PPG).
   Rebounding: Massive interior leaps — Julius Randle (2016, +10.2 RPG) and Danny Fortson (2001, +9.6 RPG) dominate the list.
   Assists: Skylar Mays (2023, +7.7 APG) and Jeremy Lin (2012, +4.8 APG) headline seasons of sudden playmaking emergence.
2) Era & Team Comparisons
  - Compare average player size (height/weight) between 1990s, 2000s, 2010s, and 2020s
   1990s → 2000s: Players slightly grew taller and heavier (≈ +0.2 cm, +0.8 kg)
   2010s: Size stabilized near 200 cm and 100 kg
   2020s: Noticeable decline in both height(198.82 cm) and weight(97.78 kg)
  - Identify which teams consistently produce top-performing players.
   The Golden State Warriors (GSW) lead all franchises with 33 total Top 25 appearances. They are followed immediately by the Los Angeles Lakers (LAL) and the Minnesota Timberwolves (MIN), who are tied with 32 appearances each. Other consistent contenders include the Milwaukee Bucks (MIL) and Boston Celtics (BOS), both landing in     the Top 25 28 times.
  - Look at rookies vs veterans - how do their contributions differ?
   The data confirms a clear leap in development. On average, a player's performance increases markedly after his debut season in all major categories.
   Scoring: Veterans average +1.52 points more (6.87) than their rookie counterparts (5.35)
   Rebounding: Veterans score +0.56 more rebounds (3.06 vs. 2.50)
   Playmaking: Veterans give out +0.35 more assists (1.53 vs. 1.18)
3) MVP & Dream Team
  - Use a weighted index (e.g., 40% points, 30% rebounds/assists, 30% efficiency) to find an MVP for a given season.
   The formula was designed to create a balanced score, rewarding production, efficiency, and overall team impact. Only players with 60 or more games played (gp >= 60) were eligible.
   Points: 40% weight
   Net Rating: 20% weight (as a proxy for team success)
   Assists: 15% weight
   Rebounds: 15% weight
   True Shooting % (TS%): 10% weight
   Shaquille O'Neal: Won the statistical MVP 4 consecutive times (1998-2002). LeBron James: Dominated for 5 consecutive seasons (2009-2013). Giannis Antetokounmpo: Captured the title 3 years in a row (2019-2022). Stephen Curry's 2015-16 season (mvp_score: 24.2) stands out as the highest-scoring MVP season in the dataset.
  - Build your dream starting 5 (PG, SG, SF, PF, C) using stats across all seasons.
   Position Assignment: Players were assigned a primary position (PG, SG, etc.) based on their average height.
   MVP Score: A custom weighted formula (score) was created to rank players, balancing scoring (avg_pts), playmaking (avg_ast, avg_reb), and overall team impact (avg_net_rating).
   Selection: The query selected the #1 ranked player for each of the five positions based on this composite score.
   Final Dream Team:
   PG: Stephen Curry
   SG: James Harden
   SF: LeBron James
   PF: Kevin Durant
   C: Joel Embiid
  - Bonus: Compare your MVP pick with the actual NBA MVP that season.
   Each season, I used my custom MVP Score formula to identify the player with the highest overall impact based on statistical performance (scoring, assists, rebounds, and net rating). I then compared my predicted MVP to the official NBA MVP for that same season.
   Comparison Key:
   “+” → My MVP pick matched the actual NBA MVP
   “–” → My MVP pick differed from the official MVP
   Results Summary: Across all analyzed seasons, my model correctly matched the official NBA MVP 13 out of 27 times (~48%). Notably consistent matches occurred during dominant individual eras — such as LeBron James (2008–2013), Stephen Curry (2014–2016), and Giannis Antetokounmpo (2019–2020).

## 💭 Conclusion
  This project highlights how data analytics can uncover hidden performance trends, validate greatness across eras, and objectively evaluate MVP races beyond media narratives. By combining SQL logic, statistical modeling, and basketball insight, I built a framework that balances numbers with basketball context — proving that the     “GOAT” debate can be explored through data as much as passion. Huge thanks to AlexTheAnalyst and AnalystBuilder for their incredible tutorials, guidance, and inspiration in developing this project! 🙌 
   
