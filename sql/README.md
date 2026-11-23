# CIS 3400 — Luxury Gym Database (small manual dataset)

This is a **small MySQL 8+ version** of the six-table Luxury Gym project. It uses a database named `luxury_gym`. Run it only after confirming the database name is safe to use; existing tables are not automatically deleted.

## Row counts

| Table | Rows |
|---|---:|
| `members` | 8 |
| `membership_plans` | 4 |
| `locations` | 2 |
| `memberships` | **4** |
| `gym_visits` | 24 |
| `payments` | 6 |

**Important:** There are exactly **4 membership subscription records** in `memberships` and **4 plan options** in `membership_plans`. Only members 1–4 hold subscriptions; members 5–8 have profiles but have not subscribed. This keeps the database small while allowing examples of non-subscribers and `LEFT JOIN`.

The six tables preserve the original schema and relationships, including required foreign keys. These are fictional records and are intentionally small, so results illustrate SQL concepts rather than meaningful business trends.

## File structure

```text
sql/
  00_create_database.sql
  01_insert_members.sql
  02_insert_membership_plans.sql
  03_insert_locations.sql
  04_insert_memberships.sql
  05_insert_gym_visits.sql
  06_insert_payments.sql
  07_verify_counts.sql
  08_five_questions.sql
```

## How to load manually from the MySQL CLI

1. Open Terminal and start MySQL with `mysql -u root -p` (or your usual login command).
2. Use `SOURCE` to execute each script in the order shown below. Replace `/absolute/path/...` with the actual path to the extracted folder.

```sql
SOURCE /absolute/path/cis3400_small_manual/sql/00_create_database.sql;
SOURCE /absolute/path/cis3400_small_manual/sql/01_insert_members.sql;
SOURCE /absolute/path/cis3400_small_manual/sql/02_insert_membership_plans.sql;
SOURCE /absolute/path/cis3400_small_manual/sql/03_insert_locations.sql;
SOURCE /absolute/path/cis3400_small_manual/sql/04_insert_memberships.sql;
SOURCE /absolute/path/cis3400_small_manual/sql/05_insert_gym_visits.sql;
SOURCE /absolute/path/cis3400_small_manual/sql/06_insert_payments.sql;
SOURCE /absolute/path/cis3400_small_manual/sql/07_verify_counts.sql;
SOURCE /absolute/path/cis3400_small_manual/sql/08_five_questions.sql;
```

Alternatively, open each file in MySQL Workbench and execute it in the same order.

**Run the INSERT files only once on empty tables.** Re-running them will cause duplicate primary-key errors. This package intentionally contains no `DROP DATABASE`, `DROP TABLE`, or `TRUNCATE` statements.

## Relationship order

`members`, `membership_plans`, and `locations` are parent tables. Insert into those before `memberships`, `gym_visits`, and `payments` so foreign keys remain valid.

- `memberships.member_id` → `members.member_id`
- `memberships.plan_id` → `membership_plans.plan_id`
- `gym_visits.member_id` → `members.member_id`
- `gym_visits.location_id` → `locations.location_id`
- `payments.membership_id` → `memberships.membership_id`
- `payments.location_id` → `locations.location_id`

## Analytics

`08_five_questions.sql` implements the five questions in your existing `five_questions.md`, including their subquestions: peak usage by day/time and age, plan selection, demographics, usage by location, and monthly revenue by location/borough. The sample contains data across September–November 2026. Payments attributed to a location represent recorded revenue assigned to that branch, not necessarily cash collected at the location of a visit.

## For your original repository

Copy the `sql` folder into the GitHub repository and update the main README to explain that this is a small teaching dataset. Do **not** use the older, large synthetic-data insertion script against the new database.
