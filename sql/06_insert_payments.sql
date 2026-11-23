USE luxury_gym;
-- 6 payments for 4 subscriptions; memberships 2 and 4 have split payments.
-- For every membership, total paid = its plan price.
INSERT INTO payments
    (payment_id, membership_id, location_id, amount, paid_at)
VALUES
    (1, 1, 1, 75.00, '2026-11-01'),
    (2, 2, 2, 75.00, '2026-11-01'),
    (3, 2, 2, 50.00, '2026-11-02'),
    (4, 3, 1, 195.00, '2026-10-15'),
    (5, 4, 2, 200.00, '2026-09-01'),
    (6, 4, 1, 145.00, '2026-09-15');
