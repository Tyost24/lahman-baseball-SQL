Select * 
from teams


Select *
from people



--------------------------------------------------

-- 1. What range of years for baseball games played does the provided database cover?

--from 1864 to 2016, here i used Union all to combine the two select statements.

Select Distinct(yearid)
from teams as t
Union all 
Select Distinct(yearid)
From collegeplaying as c
order by yearid DESC


-- 2. Find the name and height of the shortest player in the database. How many games did he play in? What is the name of the team for which he played?

-- Eddie Gaedel is the shortest played at 43CM  for the St.Louis Browns and he only played one game.


Select Distinct concat(cast(p.namefirst as text),' ', cast(p.namelast as text)) as full_name, p.height, t.name, a.g_all as games_played
from people as p
Left join appearances as a
on p.playerid = a.playerid
Left join teams as t
on a.teamid = t.teamid
Group by p.namefirst, p.namelast, p.height, t.name, games_played, full_name
Order by p.height

-- this is simpler code, both are correct. i used using here becasue playerid are the same in both tables.
SELECT namefirst, namelast, height, weight, g_all, teamID
FROM people
LEFT JOIN appearances
USING(playerid)
ORDER BY height
LIMIT 10;

-- 3. Find all players in the database who played at Vanderbilt University. Create a list showing each player’s first and last names as well as the total salary they earned in the major leagues. Sort this list in descending order by the total salary earned. Which Vanderbilt player earned the most money in the majors?

-- David Price is the highest paid player at 24553888

Select Distinct concat(cast(p.namefirst as text),' ', cast(p.namelast as text)) as full_name, 
sum(s.salary) as salary, 
sc.schoolname as school
from people as p
left join salaries as s
on p.playerid = s.playerid
left Join collegeplaying as c
on p.playerid = c.playerid
Left Join schools as sc
on c.schoolid = sc.schoolid
Where sc.schoolname = 'Vanderbilt University'
and salary is not NULL
and sc.schoolid is not NULL
Group by full_name, school
Order by salary Desc

--same answer but a simplier version
SELECT playerid,
		namefirst,
		namelast,
		SUM(salary)
FROM people
LEFT JOIN salaries
USING(playerid)
WHERE playerid IN (SELECT playerid
					FROM collegeplaying
					WHERE schoolid = 'vandy')
AND salary IS NOT NULL
GROUP BY playerid, namefirst, namelast
ORDER BY SUM(salary) DESC;

-- 4. Using the fielding table, group players into three groups based on their position: label players with position OF as "Outfield", those with position "SS", "1B", "2B", and "3B" as "Infield", and those with position "P" or "C" as "Battery". Determine the number of putouts made by each of these three groups in 2016.

-- Outfield: 29560, Infield: 58934, Battery: 39182.

Select
	sum(po) as total_putouts,
	CASE WHEN pos = 'OF' THEN 'Outfield'
	WHEN pos = 'SS' OR pos = '1B' OR pos = '2B' OR pos = '3B' THEN 'infield'
	WHEN pos = 'p' OR pos = 'C' THEN 'Battery'
	END AS position
FROM fielding
WHERE yearid = '2016'
GROUP by position

-- same thing as above but with no nulls.
SELECT 
	CASE WHEN pos = 'OF' THEN 'Outfield'
	WHEN pos IN ('SS', '1B', '2B', '3B') THEN 'Infield'
	WHEN pos IN ('P', 'C') THEN 'Battery'
	END AS position,
	SUM(PO)
FROM fielding
WHERE yearid = 2016
GROUP BY position

 -- 5. Find the average number of strikeouts per game by decade since 1920. Round the numbers you report to 2 decimal places. Do the same for home runs per game. Do you see any trends?
-- the averages go down by decade for the most part. 

Select 
SUM(so) as batter, 
SUM(soa) as pitcher, 
(ROUND(CAST(SUM(SO) AS numeric)/CAST(SUM(g/2) AS numeric), 2)) AS avg_so,
(ROUND(CAST(SUM(HR) AS numeric)/CAST(SUM(g/2) AS numeric), 2)) AS avg_hr,
CASE WHEN yearid BETWEEN 1920 AND 1929 THEN '1920s'
	WHEN yearid BETWEEN 1930 AND 1939 THEN '1930s'
	WHEN yearid BETWEEN 1940 AND 1949 THEN '1940s'
	When yearid Between 1950 AND 1959 THen '1950s'
	When yearid Between 1960 and 1969 Then '1960s'
	WHEn yearid Between 1970 and 1979 THEN '1970s'
	WHEN yearid Between 1980 and 1989 then '1980s'
	WHEN yearid Between 1990 and 1999 then '1990s'
	When yearid Between 2000 and 2009 then '2000s'
	When yearid Between 2010 and 2019 then '2010s'
	End As decade
FROM teams
Where yearid >= 1920
GROUP BY decade
order by decade DESC;

-- here I used a formula instead of a Case statement and the order is reversed.
SELECT (yearid)/10*10 AS decade, 
		SUM(so) as so_batter, SUM(soa) as so_pitcher, 
		ROUND(CAST(SUM(so) as dec) / CAST(SUM(g/2) as dec), 2) as so_per_game,
		ROUND(CAST(SUM(hr) as dec) / CAST(SUM(g/2) as dec), 2) as hr_per_game
FROM teams
WHERE (yearid)/10*10 >= 1920
GROUP BY decade
ORDER BY decade;


-- 6. Find the player who had the most success stealing bases in 2016, where success is measured as the percentage of stolen base attempts which are successful. (A stolen base attempt results either in a stolen base or being caught stealing.) Consider only players who attempted at least 20 stolen bases.
 -- Chris Owings had the most at 91 Perceent


Select
Distinct concat(cast(namefirst as text),' ', cast(namelast as text)) as full_name,
Sum(sb) as Stolen,
Sum(cs) as Steal_Fail,
ROUND(CAST(SUM(SB) AS numeric)/CAST((SUM(SB)+SUM(CS)) AS numeric), 2) AS Success_Stolen
from people
Left Join batting
Using(playerid)
Where yearID = 2016
Group by full_name
Having (sum(sb)+sum(cs)) >= 20
order by Success_Stolen DESC



-- 7.  A.From 1970 – 2016, what is the largest number of wins for a team that did not win the world series? B.What is the smallest number of wins for a team that did win the world series? Doing this will probably result in an unusually small number of wins for a world series champion – determine why this is the case. Then redo your query, excluding the problem year. C.How often from 1970 – 2016 was it the case that a team with the most wins also won the world series? What percentage of the time?

--A. Seattle is the team with the largest number of wins that did not win the world series

Select yearid,
teamid,
w,
wswin
from teams
Where yearid Between 1970 and 2016
And wswin = 'N'
Order by w DESC


-- B. What is the smallest number of wins for a team that did win the world series
-- Los Angelas has the smallest number of win.

SELECT yearid, 
teamid, 
w, 
wswin
FROM teams
WHERE yearid BETWEEN 1970 AND 2016
	AND wswin = 'Y'
ORDER BY w


-- C. How often from 1970 – 2016 was it the case that a team with the most wins also won the world series? What percentage of the time?

-- 25 pecent of the time the team with the most wins also wins the wolrd series.


WITH winnies AS (
	SELECT yearid, teamid, w, wswin,
	MAX(w) OVER(PARTITION BY yearid) AS most_wins,
	CASE WHEN wswin = 'Y' THEN CAST(1 AS numeric)
		ELSE CAST(0 AS numeric) END AS ynbin
	FROM teams
	WHERE yearid BETWEEN 1970 AND 2016
)

SELECT SUM(ynbin) AS most_wins_wswin, COUNT(DISTINCT yearid) AS all_years, ROUND(SUM(ynbin)/COUNT(DISTINCT yearid)*100,2) AS perc_most_wins_wswin
FROM winnies
WHERE w = most_wins;

--8. Using the attendance figures from the homegames table, find the teams and parks which had the top 5 average attendance per game in 2016 (where average attendance is defined as total attendance divided by number of games). Only consider parks where there were at least 10 games played. Report the park name, team name, and average attendance. Repeat for the lowest 5 average attendance.


-- Top
SELECT park_name, teams.name AS team, SUM(h.attendance)/SUM(h.games) AS avg_attendance
FROM homegames AS h
LEFT JOIN parks
USING(park)
LEFT JOIN teams
ON h.team = teams.teamid AND h.year = teams.yearid
WHERE year = 2016
GROUP BY park_name, teams.name
HAVING SUM(games) >= 10
ORDER BY avg_attendance DESC

-- Bottom
SELECT park_name, teams.name AS team, SUM(h.attendance)/SUM(h.games) AS avg_attendance
FROM homegames AS h
LEFT JOIN parks
USING(park)
LEFT JOIN teams
ON h.team = teams.teamid AND h.year = teams.yearid
WHERE year = 2016
GROUP BY park_name, teams.name
HAVING SUM(games) >= 10
ORDER BY avg_attendance

--9. Which managers have won the TSN Manager of the Year award in both the National League (NL) and the American League (AL)? Give their full name and the teams that they were managing when they won the award.

WITH tsn_nl AS
(SELECT playerid, awardid, yearid, lgid
FROM awardsmanagers
WHERE awardid = 'TSN Manager of the Year'
	AND lgid = 'NL'),

tsn_al AS
(SELECT playerid, awardid, yearid, lgid
FROM awardsmanagers
WHERE awardid = 'TSN Manager of the Year'
	AND lgid = 'AL'),
	
winners_only AS
(SELECT tsn_nl.playerid, namefirst, namelast,
	tsn_nl.awardid, 
	tsn_nl.yearid AS nl_year, 
	tsn_al.yearid AS al_year
FROM tsn_nl
INNER JOIN tsn_al
USING(playerid)
LEFT JOIN people
USING(playerid))

SELECT subq.playerid, namefirst, namelast, team, awardid, year, league
FROM(SELECT nl_year AS year, playerid, namefirst, namelast, awardid
	 FROM winners_only
	 UNION
	 SELECT al_year, playerid, namefirst, namelast, awardid
	 FROM winners_only) AS subq
LEFT JOIN
(SELECT nl_year AS year, 'nl' AS league
	 FROM winners_only
	 UNION
	 SELECT al_year AS year, 'al'
	 FROM winners_only) AS subq2
USING(year)
LEFT JOIN 
(SELECT playerid, yearid, teamid, name AS team
FROM managers
LEFT JOIN teams
USING(teamid, yearid)) AS subq3
ON subq.playerid = subq3.playerid AND subq.year = subq3.yearid
ORDER BY year;

-- 10. Find all players who hit their career highest number of home runs in 2016. Consider only players who have played in the league for at least 10 years, and who hit at least one home run in 2016. Report the players' first and last names and the number of home runs they hit in 2016.

WITH maxhr AS (
	SELECT playerid,
			yearid,
			hr,
			MAX(hr) OVER (PARTITION BY playerid) AS maxhr,
			CASE WHEN hr = MAX(hr) OVER (PARTITION BY playerid) THEN 'yes'
			ELSE 'no' END AS career_high_2016
	FROM batting
)
SELECT p.playerid,
		p.namefirst,
		p.namelast,
		m.yearid,
		m.hr,
		m.maxhr
FROM people AS p
LEFT JOIN maxhr AS m
ON p.playerid = m.playerid
WHERE m.hr != 0
AND m.yearid = 2016
AND career_high_2016 = 'yes'
AND m.playerid IN (SELECT playerid
				  FROM batting
				  GROUP BY playerid
				  HAVING COUNT(DISTINCT yearid) >= 10)
GROUP BY 1,2,3,4,5,6