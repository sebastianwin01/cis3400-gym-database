USE luxury_gym;
-- Question 2: Which membership plans have been selected most frequently?

SELECT mp.plan_name,
       COUNT(ms.membership_id) AS subscriptions
FROM membership_plans mp
LEFT JOIN memberships ms ON ms.plan_id = mp.plan_id
GROUP BY mp.plan_id, mp.plan_name
ORDER BY subscriptions DESC, mp.plan_name;
