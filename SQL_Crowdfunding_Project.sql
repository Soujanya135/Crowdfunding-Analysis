-- 	SQL_CROWDFUNDING PROJECT
ALTER TABLE crowdfunding_creator_sql CHANGE `ï»¿id` id INT;

ALTER TABLE crowdfunding_category_sql CHANGE `ï»¿id` id INT;

ALTER TABLE crowdfunding_location_sql CHANGE `ï»¿id` id INT;

SELECT 
  FROM_UNIXTIME(p.created_at) AS created_date,
  p.name AS project_name,
  p.state,
  p.goal,
  p.pledged
FROM projects p;

-- 5.a Total Number of Projects by Outcome:
SELECT state, COUNT(*) AS total_projects
FROM projects
GROUP BY state;


-- 5.b Total Projects by Location:
SELECT l.state AS location_state, COUNT(*) AS total_projects
FROM projects p
LEFT JOIN crowdfunding_location_sql l ON p.location_id = l.id
GROUP BY l.state;

-- 5.c Total Projects by Category
SELECT c.name AS category_name, COUNT(*) AS total_projects
FROM projects p
LEFT JOIN crowdfunding_category_sql c ON p.category_id = c.id
GROUP BY c.name;

-- 5.d Total Projects by Year, Month:
SELECT 
  YEAR(FROM_UNIXTIME(p.created_at)) AS year,
  MONTH(FROM_UNIXTIME(p.created_at)) AS month_number,
  MONTHNAME(FROM_UNIXTIME(p.created_at)) AS month_name,
  COUNT(*) AS total_projects
FROM projects p
GROUP BY year, month_number, month_name
ORDER BY year, month_number;

-- 6. Successful Projects
-- 6.a Amount Raised (only for successful):
SELECT SUM(usd_pledged) AS total_raised
FROM projects
WHERE state = 'successful';

-- 6.b Number of Backers:
SELECT count(backers_count) AS total_backers
FROM projects
WHERE state = 'successful';

-- 6.c Avg. Duration for Successful Projects:
SELECT 
  ROUND(AVG((state_changed_at - launched_at) / 86400), 0) AS avg_duration_days
FROM projects
WHERE state = 'successful';

-- 7. Top Successful Projects
-- 7.a By Backers:
SELECT name, backers_count
FROM projects
WHERE state = 'successful'
ORDER BY backers_count DESC
LIMIT 5;

-- 7.b By Amount Raised:
SELECT name, usd_pledged
FROM projects
WHERE state = 'successful'
ORDER BY usd_pledged DESC
LIMIT 5;

-- 8. Percentage of Successful Projects
-- 8.a Overall:
SELECT 
  ROUND(100 * SUM(state = 'successful') / COUNT(*), 2) AS success_percentage
FROM projects;

-- 8.b By Category:
SELECT 
  c.name AS category_name,
  ROUND(100 * SUM(p.state = 'successful') / COUNT(*), 2) AS success_percentage
FROM projects p
LEFT JOIN crowdfunding_category_sql c ON p.category_id = c.id
GROUP BY c.name;

-- 8.c By Year/Month:
SELECT 
  YEAR(FROM_UNIXTIME(created_at)) AS year,
  MONTH(FROM_UNIXTIME(created_at)) AS month_number,
  MONTHNAME(FROM_UNIXTIME(created_at)) AS month_name,
  ROUND(100 * SUM(state = 'successful') / COUNT(*), 2) AS success_percentage
FROM projects
GROUP BY year, month_number, month_name
ORDER BY year, month_number;

-- 8.d By Goal Range:
SELECT 
  CASE 
    WHEN goal <= 1000 THEN '0-1K'
    WHEN goal <= 5000 THEN '1K-5K'
    WHEN goal <= 10000 THEN '5K-10K'
    ELSE '10K+'
  END AS goal_range,
  ROUND(100 * SUM(state = 'successful') / COUNT(*), 2) AS success_percentage
FROM projects
GROUP BY goal_range;
