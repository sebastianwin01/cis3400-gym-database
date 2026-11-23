USE luxury_gym;
-- Question 4: How does gym usage compare by location?
-- Morning: before 12:00; afternoon: 12:00-16:59; evening: 17:00+.

-- Q4(a): Peak time period by location (compare counts per branch).
SELECT l.location_name,
       CASE WHEN HOUR(v.check_in_at) < 12 THEN 'Morning'
            WHEN HOUR(v.check_in_at) < 17 THEN 'Afternoon'
            ELSE 'Evening' END AS time_period,
       COUNT(*) AS visits
FROM gym_visits v
JOIN locations l ON l.location_id = v.location_id
GROUP BY l.location_id, l.location_name, time_period
ORDER BY l.location_name, visits DESC, time_period;
