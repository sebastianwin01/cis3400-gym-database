USE luxury_gym;
-- Should return: members 8, membership_plans 4, locations 2,
-- memberships 4, gym_visits 24, payments 6.
SELECT 'members' AS table_name, COUNT(*) AS row_count FROM members
UNION ALL SELECT 'membership_plans', COUNT(*) FROM membership_plans
UNION ALL SELECT 'locations', COUNT(*) FROM locations
UNION ALL SELECT 'memberships', COUNT(*) FROM memberships
UNION ALL SELECT 'gym_visits', COUNT(*) FROM gym_visits
UNION ALL SELECT 'payments', COUNT(*) FROM payments;

-- Every membership should have received exactly its listed plan price.
SELECT ms.membership_id,
       mp.plan_name,
       mp.price AS expected_amount,
       COALESCE(SUM(p.amount), 0) AS received_amount
FROM memberships ms
JOIN membership_plans mp ON mp.plan_id = ms.plan_id
LEFT JOIN payments p ON p.membership_id = ms.membership_id
GROUP BY ms.membership_id, mp.plan_name, mp.price
ORDER BY ms.membership_id;

-- Confirm visits occurred within that member's membership dates.
-- Should return 0 rows for this sample dataset.
SELECT v.visit_id, v.member_id, v.check_in_at
FROM gym_visits v
WHERE NOT EXISTS (
    SELECT 1
    FROM memberships ms
    WHERE ms.member_id = v.member_id
      AND DATE(v.check_in_at) >= ms.start_date
      AND (ms.end_date IS NULL OR DATE(v.check_in_at) <= ms.end_date)
);
