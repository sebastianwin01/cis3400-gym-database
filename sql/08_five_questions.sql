USE luxury_gym;
-- Each query answers a question or subquestion from five_questions.md.
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

-- Q2: Which membership plans have been selected most frequently?
SELECT mp.plan_name,
       COUNT(ms.membership_id) AS subscriptions
FROM membership_plans mp
LEFT JOIN memberships ms ON ms.plan_id = mp.plan_id
GROUP BY mp.plan_id, mp.plan_name
ORDER BY subscriptions DESC, mp.plan_name;

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

-- Q5(a): Monthly revenue credited to each location.
SELECT DATE_FORMAT(p.paid_at, '%Y-%m') AS payment_month,
       l.location_name,
       SUM(p.amount) AS revenue
FROM payments p
JOIN locations l ON l.location_id = p.location_id
GROUP BY DATE_FORMAT(p.paid_at, '%Y-%m'), l.location_id, l.location_name
ORDER BY payment_month, l.location_name;

-- Q5(b): Monthly revenue credited to each borough.
SELECT DATE_FORMAT(p.paid_at, '%Y-%m') AS payment_month,
       l.borough_name,
       SUM(p.amount) AS revenue
FROM payments p
JOIN locations l ON l.location_id = p.location_id
GROUP BY DATE_FORMAT(p.paid_at, '%Y-%m'), l.borough_name
ORDER BY payment_month, l.borough_name;
