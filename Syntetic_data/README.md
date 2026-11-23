# Luxury Gym — synthetic dataset

This dataset is fictional and aligns to the six-table `luxury_gym` ERD.
Data cutoff: **2026-11-22**. All customers, email addresses, and phone numbers are artificial.

## Dataset sizes

| Table | Rows |
|---|---:|
| membership_plans | 6 |
| members | 240 |
| locations | 5 |
| memberships | 699 |
| gym_visits | 12,644 |
| payments | 752 |

## Import into MySQL Workbench
1. Create the six tables from your ERD (or use your existing `luxury_gym` database).
2. Make sure the six tables are **empty**. This file uses explicit IDs starting at 1 and should be run only once per empty database.
3. Open `luxury_gym_synthetic_data.sql` in MySQL Workbench (File > Open SQL Script).
4. Execute the entire script. It starts with `USE luxury_gym;` and loads parent tables before dependent tables.
5. Verify with `SELECT COUNT(*) FROM gym_visits;` and other counts.

## Contents
- `membership_plans.csv`: pricing and durations, duration in months
- `members.csv`: fictional member profiles and joining dates
- `locations.csv`: five NYC locations and hours; `is_active` uses 1 for true
- `memberships.csv`: term starts, ends, plan and member references, renewals
- `gym_visits.csv`: historical check-in and check-out times, including peak hours
- `payments.csv`: paid memberships, including occasional split payments

## Business logic / caveats
- Every membership belongs to one member and one plan.
- Membership terms do not overlap for the same member.
- Visit check-ins fall within at least one active membership term and before 2026-11-22.
- Every payment belongs to a membership and a location; payments per membership sum to the plan's listed price.
- Members can use all locations (multi-location access).
- Payment records are synthetic successful payments, not refunds or outstanding balances.
- The data include a plausible weekday-evening traffic bias, membership renewals and inactive members for SQL practice, but are not calibrated to actual NYC gym statistics.

## Example analysis queries

```sql
-- Visit volume by day of week and hour
SELECT DAYNAME(check_in_at) AS weekday,
       HOUR(check_in_at) AS hour_of_day,
       COUNT(*) AS visits
FROM gym_visits
GROUP BY DAYNAME(check_in_at), HOUR(check_in_at)
ORDER BY visits DESC;

-- Revenue by location
SELECT l.location_name, ROUND(SUM(p.amount), 2) AS revenue
FROM payments p
JOIN locations l ON l.location_id = p.location_id
GROUP BY l.location_id, l.location_name
ORDER BY revenue DESC;

-- Distinct members with a currently valid membership (on dataset cutoff)
SELECT COUNT(DISTINCT member_id) AS active_members
FROM memberships
WHERE '2026-11-22' BETWEEN start_date AND end_date;
```
