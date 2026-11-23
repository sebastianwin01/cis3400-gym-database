USE luxury_gym;
-- Question 1: How does peak gym usage break down?
-- Morning: before 12:00; afternoon: 12:00-16:59; evening: 17:00+.

-- Q1(a): What days and time periods have the highest number of visits?
SELECT DAYNAME(check_in_at) AS weekday,
       CASE WHEN HOUR(check_in_at) < 12 THEN 'Morning'
            WHEN HOUR(check_in_at) < 17 THEN 'Afternoon'
            ELSE 'Evening' END AS time_period,
       COUNT(*) AS visits
FROM gym_visits
GROUP BY DAYNAME(check_in_at),
         CASE WHEN HOUR(check_in_at) < 12 THEN 'Morning'
              WHEN HOUR(check_in_at) < 17 THEN 'Afternoon'
              ELSE 'Evening' END
ORDER BY visits DESC, weekday, time_period;

-- Q1(b): How many DISTINCT members in each age group visit each period?
SELECT CASE WHEN TIMESTAMPDIFF(YEAR, m.date_of_birth, DATE(v.check_in_at)) < 30 THEN 'Under 30'
            WHEN TIMESTAMPDIFF(YEAR, m.date_of_birth, DATE(v.check_in_at)) < 45 THEN '30-44'
            ELSE '45+' END AS age_group,
       CASE WHEN HOUR(v.check_in_at) < 12 THEN 'Morning'
            WHEN HOUR(v.check_in_at) < 17 THEN 'Afternoon'
            ELSE 'Evening' END AS time_period,
       COUNT(DISTINCT v.member_id) AS distinct_members
FROM gym_visits v
JOIN members m ON m.member_id = v.member_id
WHERE m.date_of_birth IS NOT NULL
GROUP BY age_group, time_period
ORDER BY age_group, time_period;
