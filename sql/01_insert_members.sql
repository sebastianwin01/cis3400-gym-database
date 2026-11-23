USE luxury_gym;
-- 8 members: 4 have memberships, 4 have profiles without a subscription.
INSERT INTO members
    (member_id, first_name, last_name, email, phone, date_of_birth, joining_date)
VALUES
    (1, 'Ava', 'Rivera', 'ava.rivera@example.com', '718-555-0101', '1999-02-14', '2026-09-01'),
    (2, 'Leo', 'Chen', 'leo.chen@example.com', '917-555-0102', '1988-05-22', '2026-09-03'),
    (3, 'Maya', 'Brooks', 'maya.brooks@example.com', '347-555-0103', '1974-11-08', '2026-09-08'),
    (4, 'Daniel', 'Lopez', 'daniel.lopez@example.com', '212-555-0104', '1963-04-30', '2026-09-10'),
    (5, 'Nora', 'Patel', 'nora.patel@example.com', '718-555-0105', '2002-07-09', '2026-10-02'),
    (6, 'Omar', 'Davis', 'omar.davis@example.com', '917-555-0106', '1981-03-11', '2026-10-05'),
    (7, 'Priya', 'Kim', 'priya.kim@example.com', '347-555-0107', '1995-12-01', '2026-10-10'),
    (8, 'Sam', 'Jones', 'sam.jones@example.com', '212-555-0108', '1958-09-21', '2026-10-15');
