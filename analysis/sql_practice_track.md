# SQL Practice Track — CIS 3400 Gym Database

Use the real schema in `sql/create_tables.sql` to practice both DataCamp courses. The queries below are **tasks**, not completed homework solutions.

## Before starting
1. Run `sql/create_database.sql`, followed by `sql/create_tables.sql` in MySQL 8.4.
2. Inspect the tables with `SHOW TABLES;` and `DESCRIBE members;`.
3. Next, add fictional data for each table. Keep dates and foreign keys consistent.

## Joining Data in SQL
1. INNER JOIN `members` to `memberships` to list every membership and the corresponding member name.
2. JOIN `memberships`, `membership_plans`, and `payments` to list the plan and payment amount.
3. LEFT JOIN `trainers` to `class_sessions` to include trainers who have never taught a class.
4. JOIN `enrollments`, `members`, `class_sessions`, and `class_types` to list which members booked which class.
5. Use a subquery with `IN` to find members enrolled in Yoga.
6. Use `NOT EXISTS` to find members who have never booked a class.

## Intermediate SQL
7. Use `CASE WHEN` to classify members by age (use a fixed report date).
8. Count enrollments per class type with `GROUP BY`.
9. Use `HAVING` to display classes with at least 3 bookings.
10. Calculate monthly completed-payment revenue using `SUM` and a month grouping.
11. Calculate attendance rate per class type, excluding canceled bookings.
12. Use `ROW_NUMBER()` to rank the most-booked class sessions within each class type.

## Project acceptance tests
- A duplicate member email is rejected.
- A membership with an end date before the start date is rejected.
- A payment referencing a nonexistent membership is rejected.
- A second enrollment for the same member and class session is rejected.
- A class capacity of 0 is rejected.
- Queries still include trainers without sessions when using LEFT JOIN.

## Limitations of the initial schema
The table constraints **do not yet** prevent overbooking, overlapping trainer schedules, or enrolling without an active membership. Those require additional transactional/business logic. Sample data and the five formal analytical reports are later stages.
