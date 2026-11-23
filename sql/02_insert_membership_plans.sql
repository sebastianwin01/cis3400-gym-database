USE luxury_gym;
-- 4 plan options, not to be confused with 4 membership records.
INSERT INTO membership_plans
    (plan_id, plan_name, plan_level, duration, price)
VALUES
    (1, 'Essential Monthly', 'Essential', 1, 75.00),
    (2, 'Plus Monthly', 'Plus', 1, 125.00),
    (3, 'Elite Monthly', 'Elite', 1, 195.00),
    (4, 'Plus Quarterly', 'Plus', 3, 345.00);
