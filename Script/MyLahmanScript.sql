Select * 
from teams

Select *
from teams



--------------------------------------------------

-- 1. What range of years for baseball games played does the provided database cover?

--from 1864 to 2016

Select Distinct(yearid)
from teams as t
Union all 
Select Distinct(yearid)
From collegeplaying as c
order by yearid DESC


-- 2. Find the name and height of the shortest player in the database. How many games did he play in? What is the name of the team for which he played?

-- Edward Carl is the shortest played at 43CM  for the St.Louis Browns and he only played one game.


Select p.namegiven, p.height, t.name, a.g_all as games_played
from people as p
left join appearances as a
on p.playerid = a.playerid
Left join teams as t
on a.teamid = t.teamid
Group by p.namegiven, p.height, t.name, games_played
Order by p.height
