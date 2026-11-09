# Luxury Gym Management Database

**Course:** CIS 3400  
**Database:** MySQL 8  
**Focus:** Relational database design, data integrity, and SQL analysis

## Project overview

This project develops a relational database for a fictional luxury gym with multiple locations. The database organizes information about **members, membership plans, subscriptions, gym visits, payments, and locations**.

The goal is to maintain consistent records and use SQL to explore gym attendance, membership preferences, and revenue across branches. This is a **database design and analysis project**, not a gym website or mobile app.

## Business objectives

- Store member information and available membership plans.
- Track members' subscriptions and membership history.
- Record gym check-ins and check-outs at different locations.
- Record membership payments and the branch associated with each payment.
- Analyze member activity, plan popularity, and payment revenue.

**Membership access model:** A valid membership may be used at any active gym location. A member's visits are recorded at the branch actually visited; the database does not restrict membership to one home location.

## Project scope

The project uses **six tables, 34 attributes, and six foreign-key relationships**. No additional entities are planned.

| Table | Purpose | Main fields |
| --- | --- | --- |
| `members` | Member profiles | Member ID, name, email, phone, date of birth, joining date |
| `membership_plans` | Available plans | Plan ID, name, level, duration in months, price |
| `memberships` | Member subscriptions | Membership ID, member ID, plan ID, start date, end date, creation timestamp |
| `gym_visits` | Attendance at each branch | Visit ID, member ID, location ID, check-in and check-out timestamps |
| `payments` | Payments associated with subscriptions and branches | Payment ID, membership ID, location ID, amount, payment date |
| `locations` | Gym branches | Location ID, name, borough, opening time, closing time, active flag |

### Relationships

All six relationships are **one-to-many (1:N)**:

1. `members` → `memberships`
2. `membership_plans` → `memberships`
3. `members` → `gym_visits`
4. `locations` → `gym_visits`
5. `memberships` → `payments`
6. `locations` → `payments`

Primary keys identify individual records; foreign keys connect related records. The `memberships` table links members to plans, and the `gym_visits` table links members to branches.

### Basic business rules

- A member has a unique ID and email address.
- A membership refers to one existing member and one existing plan. A member may have multiple membership records over time.
- A gym visit refers to one member and one location; `check_out_at` can be `NULL` until the member leaves.
- A payment refers to one membership and one location.
- Membership `end_date` may be `NULL`; the precise interpretation of an open-ended membership must be agreed before calculating active subscriptions.
- Plan durations and payment amounts must be positive, and recorded end/check-out dates must not precede their start/check-in dates.
- All records are fictional and used for coursework.

### Out of scope

Free trials, classes, trainers, amenity reservations, payroll, inventory, payment processing, and a customer-facing app are not included in this version.

## Analytical questions

The database is designed to answer five general business questions:

| # | Question | Relevant tables |
| --- | --- | --- |
| 1 | Which days and hours are busiest at each gym location? | `gym_visits`, `locations` |
| 2 | Which membership plans are chosen most often? | `memberships`, `membership_plans` |
| 3 | How does recorded payment revenue compare across locations and boroughs? | `payments`, `locations` |
| 4 | How does gym attendance vary across member age groups? | `members`, `gym_visits` |
| 5 | How frequently do members visit, and how long do their visits last on average? | `members`, `gym_visits` |

Queries will use SQL techniques such as `JOIN`, `GROUP BY`, aggregate functions, date/time functions, `CASE`, and subqueries where useful.

## Project roadmap

> Use this checklist to track deliverables. Mark items complete when the corresponding files have been finalized and tested.

- [ ] **Step 1 — Define business requirements**  
  Describe the business objectives, basic rules, scope, and analytical questions.  
  **Deliverable:** `docs/01_business_requirements.md`

- [ ] **Step 2 — Identify entities and attributes**  
  Confirm the six tables, their columns, MySQL data types, primary keys, foreign keys, and nullable fields.  
  **Deliverable:** `docs/02_entities_and_attributes.md`

- [ ] **Step 3 — Design the ER diagram**  
  Maintain the schema in DBML and generate a Crow's Foot ER diagram showing the six one-to-many relationships.  
  **Deliverables:** `diagrams/03_gym_database.dbml`, `diagrams/gym_erd.png`

- [ ] **Step 4 — Normalize the schema**  
  Review the tables against First, Second, and Third Normal Forms (1NF, 2NF, and 3NF); document any changes.  
  **Deliverable:** `docs/04_normalization.md`

- [ ] **Step 5 — Create the MySQL database**  
  Write and run `CREATE TABLE` statements with appropriate keys, `NOT NULL`, `UNIQUE`, and `CHECK` constraints.  
  **Deliverable:** `sql/01_create_tables.sql`

- [ ] **Step 6 — Insert sample data**  
  Populate plans, branches, members, subscriptions, payments, and several months of visit activity using fictional records.  
  **Deliverable:** `sql/02_insert_data.sql` (optional CSV files in `data/`)

- [ ] **Step 7 — Validate data integrity**  
  Test referential integrity, unique values, required fields, and sensible dates and amounts.  
  **Deliverable:** `sql/03_validation.sql`

- [ ] **Step 8 — Write analytical queries**  
  Answer the five business questions and document how each result is calculated.  
  **Deliverable:** `sql/04_analysis.sql`

- [ ] **Step 9 — Summarize findings**  
  Optionally create reusable SQL views, save sample results, and summarize findings in tables or charts.  
  **Deliverables:** `sql/05_views.sql` (optional), `analysis/results.md`

- [ ] **Step 10 — Final testing and submission**  
  Rebuild the database from a clean environment, rerun the analysis, update this README, and commit the final files to GitHub.  
  **Deliverable:** Completed repository

## Suggested repository structure

```text
gym-management-database/
├── README.md
├── docs/
│   ├── 01_business_requirements.md
│   ├── 02_entities_and_attributes.md
│   └── 04_normalization.md
├── diagrams/
│   ├── 03_gym_database.dbml
│   └── gym_erd.png
├── sql/
│   ├── 01_create_tables.sql
│   ├── 02_insert_data.sql
│   ├── 03_validation.sql
│   ├── 04_analysis.sql
│   └── 05_views.sql             # Optional
├── data/                       # Optional fictional CSVs
└── analysis/
    └── results.md
```

## Example SQL analysis

**Question:** Which weekdays have the most gym visits?

```sql
SELECT
    DAYNAME(check_in_at) AS day_of_week,
    COUNT(*) AS total_visits
FROM gym_visits
GROUP BY DAYOFWEEK(check_in_at), DAYNAME(check_in_at)
ORDER BY total_visits DESC;
```

This query uses the actual `check_in_at` field and counts **visit records**, not unique members. The same analysis can be broken down by location using `gym_visits.location_id` and a join to `locations`.

## Data interpretation notes

- `check_out_at` is nullable until a member leaves; exclude unfinished visits when calculating average visit duration.
- `date_of_birth` is optional; exclude missing values from age-based calculations.
- `end_date` is optional. Membership validity must be defined consistently using plan duration and/or the recorded end date before reporting active subscriptions.
- `payments` has no payment status or refund field. Revenue reports therefore sum **recorded payment amounts**, assuming the sample payments represent completed payments.
- `membership_plans.price` describes the plan's stored price and is not necessarily the amount paid historically; use `payments.amount` for revenue analysis.
- `locations.opening_time` and `closing_time` represent general branch hours, not day-specific schedules.

## Completion criteria

- [ ] The data dictionary, DBML, ER diagram, and SQL tables agree.
- [ ] The database builds successfully from the SQL scripts.
- [ ] All six foreign keys and relevant constraints work.
- [ ] Fictional sample data covers multiple branches, plans, dates, and members.
- [ ] The five analytical questions can be answered using SQL.
- [ ] Query results and main findings are documented clearly.
- [ ] The README explains the project, structure, and how to run its scripts.

**Next milestone:** Finalize the six-table ER diagram, then document normalization before implementing the tables in MySQL.
