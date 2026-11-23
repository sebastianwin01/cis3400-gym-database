USE luxury_gym;
-- Question 3: How does gym usage break down by age group?

-- Q3(a): What age groups use the gym most regularly (by visit count)?
SELECT CASE WHEN TIMESTAMPDIFF(YEAR, m.date_of_birth, DATE(v.check_in_at)) < 30 THEN 'Under 30'
            WHEN TIMESTAMPDIFF(YEAR, m.date_of_birth, DATE(v.check_in_at)) < 45 THEN '30-44'
            ELSE '45+' END AS age_group,
       COUNT(*) AS visits,
       COUNT(DISTINCT v.member_id) AS distinct_members
FROM gym_visits v
JOIN members m ON m.member_id = v.member_id
WHERE m.date_of_birth IS NOT NULL
GROUP BY age_group
ORDER BY visits DESC;

-- Q3(b): How many subscriptions are held by each age group?
-- Age is measured on the membership start date.
SELECT CASE WHEN TIMESTAMPDIFF(YEAR, m.date_of_birth, ms.start_date) < 30 THEN 'Under 30'
            WHEN TIMESTAMPDIFF(YEAR, m.date_of_birth, ms.start_date) < 45 THEN '30-44'
            ELSE '45+' END AS age_group,
       COUNT(*) AS subscriptions
FROM memberships ms
JOIN members m ON m.member_id = ms.member_id
WHERE m.date_of_birth IS NOT NULL
GROUP BY age_group
ORDER BY subscriptions DESC;
