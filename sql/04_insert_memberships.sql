USE luxury_gym;
-- Exactly 4 membership subscriptions (one per member_id 1-4).
INSERT INTO memberships
    (membership_id, member_id, plan_id, start_date, end_date, created_at)
VALUES
    (1, 1, 1, '2026-11-01', '2026-11-30', '2026-10-30 10:00:00'),
    (2, 2, 2, '2026-11-01', '2026-11-30', '2026-10-30 11:00:00'),
    (3, 3, 3, '2026-10-15', '2026-11-14', '2026-10-14 09:30:00'),
    (4, 4, 4, '2026-09-01', '2026-11-30', '2026-08-31 16:45:00');
