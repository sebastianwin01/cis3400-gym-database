# Gym Management Database — Project Roadmap

**Course:** CIS 3400  
**Project:** Luxury Gym Management Database  
**Database:** MySQL 8  
**Focus:** Relational database design, SQL implementation, and data analysis

## Project objective

Build a database for a luxury gym that tracks **members, membership plans, gym visits, free trials, payments, fitness classes, and amenities** (such as a sauna and cold plunge). Use the resulting data to answer the five analytical questions in the project proposal.

**Scope:** This is a database-and-analysis project, **not** a full gym website or app. The database should reflect real-world gym operations while remaining small enough to implement and test.

---

## Progress tracker

> Mark each task complete by changing `[ ]` to `[x]`. Complete the design before inserting sample records or writing analytical queries.

- [ ] **Step 1 — Define business requirements**
  - [ ] Identify membership options: Basic vs. Premium, monthly vs. annual, contract vs. non-contract.
  - [ ] Define how free trials work and what counts as conversion to a paid membership.
  - [ ] Define how gym check-ins and check-outs are recorded.
  - [ ] Define class booking, class attendance, cancellation, and no-show rules.
  - [ ] Define amenity reservations, usage, and any additional charges.
  - [ ] Identify data needed for each of the five analytical questions.
  - **Deliverable:** `docs/requirements.md`

- [ ] **Step 2 — Define tables, columns, and data types**
  - [ ] Identify all entities and assign each a primary key.
  - [ ] List columns and choose suitable MySQL types (`INT`, `VARCHAR`, `DATE`, `DATETIME`, `DECIMAL`, etc.).
  - [ ] Identify foreign keys and required vs. optional fields.
  - [ ] Decide which historical information must be retained (e.g., past membership plans).
  - [ ] Prepare a data dictionary describing each field.
  - **Deliverable:** `docs/data_dictionary.md`

- [ ] **Step 3 — Create the ER diagram**
  - [ ] Draw entities and their relationships.
  - [ ] Identify one-to-many and many-to-many relationships.
  - [ ] Use junction tables for class enrollments and amenity reservations where needed.
  - [ ] Check that the diagram supports every proposed analytical question.
  - **Deliverable:** `diagrams/gym_er_diagram.png`

- [ ] **Step 4 — Normalize the schema**
  - [ ] Check First Normal Form (1NF): atomic values and no repeating groups.
  - [ ] Check Second Normal Form (2NF): non-key attributes depend on the whole key.
  - [ ] Check Third Normal Form (3NF): remove transitive dependencies.
  - [ ] Revisit the ER diagram and data dictionary if the design changes.
  - **Deliverable:** `docs/normalization.md`

- [ ] **Step 5 — Create the MySQL schema**
  - [ ] Create the database and tables in dependency order.
  - [ ] Add primary keys, foreign keys, `NOT NULL`, `UNIQUE`, and appropriate `CHECK` constraints.
  - [ ] Choose suitable `ON DELETE` / `ON UPDATE` behavior; avoid accidental deletion of history.
  - [ ] Run the schema script successfully in a fresh MySQL database.
  - **Deliverable:** `sql/01_create_tables.sql`

- [ ] **Step 6 — Insert realistic sample data**
  - [ ] Generate fictional member records with varied ages and registration dates.
  - [ ] Populate Basic and Premium plans, billing periods, and contract types.
  - [ ] Add membership histories and free trials with realistic dates.
  - [ ] Add 3–6 months of gym visits at varied times and days.
  - [ ] Populate class schedules, enrollments, attendance, and amenity usage.
  - [ ] Record membership payments and extra service charges.
  - [ ] Ensure enough variation to make each analytical query meaningful.
  - **Deliverables:** `sql/02_insert_data.sql` and optional `data/*.csv`

- [ ] **Step 7 — Validate data integrity**
  - [ ] Verify that every foreign key points to an existing record.
  - [ ] Test invalid or duplicate values and expected constraint failures.
  - [ ] Check for impossible date sequences and overlapping records where prohibited.
  - [ ] Compare attendance, reservations, and payment totals against sample expectations.
  - **Deliverable:** `sql/03_validation.sql`

- [ ] **Step 8 — Write analytical SQL queries**
  - [ ] Answer Question 1: peak gym usage, visit days/hours, age statistics, plan counts.
  - [ ] Answer Question 2: class and amenity attendance, Premium share, Basic paid usage.
  - [ ] Answer Question 3: free-trial conversion and member retention.
  - [ ] Answer Question 4: plan popularity and membership duration by group/contract type.
  - [ ] Answer Question 5: usage and amenity preferences by age group and time of day.
  - [ ] Use `JOIN`, `GROUP BY`, `HAVING`, `CASE`, aggregates, date functions, and subqueries/CTEs as appropriate.
  - [ ] Add short comments stating what each query measures.
  - **Deliverable:** `sql/04_analysis.sql`

- [ ] **Step 9 — Create reusable views and summarize findings**
  - [ ] Create useful views for daily traffic, class attendance, plan participation, and retention cohorts.
  - [ ] Save representative query results.
  - [ ] Create simple tables or charts for the five questions.
  - [ ] Explain actionable insights for staffing, class schedules, amenities, and memberships.
  - **Deliverables:** `sql/05_views.sql` and `analysis/results.md`

- [ ] **Step 10 — Final testing, documentation, and GitHub submission**
  - [ ] Rebuild the database from scratch using the SQL scripts in order.
  - [ ] Confirm all five analytical questions can be answered.
  - [ ] Add instructions, project overview, ER diagram, and findings to `README.md`.
  - [ ] Review SQL formatting and remove any sensitive or real personal information.
  - [ ] Commit and push the finished project to GitHub.
  - **Deliverables:** `README.md`, completed repository, and project report/presentation as required.

---

## Proposed database tables

| Table | Main responsibility | Key relationships |
|---|---|---|
| `members` | Member profiles and dates of birth | Referenced by visits, memberships, trials, reservations |
| `membership_plans` | Basic/Premium offerings, price, and billing configuration | Referenced by memberships |
| `memberships` | Member enrollment history, terms, start/end dates, and status | Member → plan |
| `gym_visits` | Gym entry and exit timestamps | Visit → member |
| `free_trials` | Trial start/end dates and conversion information | Trial → member; optionally converted membership |
| `amenities` | Sauna, cold plunge, and other amenity definitions | Referenced by amenity reservations |
| `amenity_reservations` | Bookings and actual amenity usage | Reservation → member and amenity |
| `class_types` | Yoga, Pilates, strength training, etc. | Referenced by scheduled sessions |
| `class_sessions` | Scheduled class time, capacity, and instructor information | Session → class type |
| `class_enrollments` | Member bookings, attendance status, and extra charges | Enrollment → member and session |
| `payments` | Membership fees and service charges | Payment → member and appropriate charge/source |

**Design notes:**

- Store **date of birth**, not only current age, so age groups can be calculated consistently.
- Keep membership **history**, not only a member's current plan.
- Distinguish **booked**, **attended**, **cancelled**, and **no-show** statuses where relevant.
- Make trial conversion and retention definitions precise (e.g., converted within 30 days, retained after 90 days).
- Avoid confusing **gym visits** with **class attendance** or **amenity usage**; they measure different activities.
- A single `payments` table may need a payment category and references to membership/extra charges; finalize these details in Step 2.

---

## Analytical questions from the proposal

### Question 1 — How does peak gym usage break down?

- [ ] Which **days** have the most member visits?
- [ ] Which **times** have the most member visits?
- [ ] How many gym members are there, and what are the **average, median, and mode** for age?
- [ ] How many members use each **membership type**?

**Main tables:** `gym_visits`, `members`, `memberships`, `membership_plans`.

### Question 2 — Which amenities and classes have the highest attendance?

- [ ] What percentage of attendance comes from **Premium** members?
- [ ] What percentage comes from **Basic** members paying for individual classes?
- [ ] Which classes are attended most frequently?
- [ ] How does amenity use vary by member/category and time?

**Main tables:** `class_sessions`, `class_enrollments`, `amenities`, `amenity_reservations`, `memberships`, `membership_plans`.

### Question 3 — What are retention rates after a free trial or first month?

- [ ] How does the free-trial program affect paid membership conversion and retention?
- [ ] Is trial participation associated with longer membership duration?

**Main tables:** `free_trials`, `members`, `memberships`.

### Question 4 — Which membership plans are most popular?

- [ ] Which plans have the most active enrollments?
- [ ] Which demographic groups select **Premium** plans more often?
- [ ] Which groups tend to choose **Basic** memberships?
- [ ] Do contract or non-contract members remain enrolled longer?

**Main tables:** `members`, `membership_plans`, `memberships`.

### Question 5 — How does usage differ by member category?

- [ ] Which age groups visit most regularly?
- [ ] Which age group has the most memberships?
- [ ] What are the peak gym hours by age group?
- [ ] Does time of day relate to which amenities members use?

**Main tables:** `members`, `gym_visits`, `memberships`, `amenity_reservations`, `amenities`.

---

## Suggested repository structure

```text
gym-management-database/
├── README.md
├── docs/
│   ├── requirements.md
│   ├── data_dictionary.md
│   └── normalization.md
├── diagrams/
│   └── gym_er_diagram.png
├── sql/
│   ├── 01_create_tables.sql
│   ├── 02_insert_data.sql
│   ├── 03_validation.sql
│   ├── 04_analysis.sql
│   └── 05_views.sql
├── data/
│   └── sample CSV files (optional)
└── analysis/
    └── results.md
```

## Example analysis query

**Question:** Which weekdays have the highest number of gym visits?

```sql
SELECT
    DAYNAME(check_in_time) AS day_of_week,
    COUNT(*) AS total_visits
FROM gym_visits
GROUP BY
    DAYOFWEEK(check_in_time),
    DAYNAME(check_in_time)
ORDER BY total_visits DESC;
```

This assumes one row per visit and a `check_in_time` field in `gym_visits`. The query counts **visits**, not unique members or total time spent in the gym.

---

## Completion criteria

- [ ] ER diagram matches the implemented schema.
- [ ] The schema can be created from an empty MySQL database.
- [ ] Sample data is fictional, consistent, and sufficient for meaningful analysis.
- [ ] Primary/foreign keys and integrity checks work as expected.
- [ ] SQL queries answer **all five** main questions and their subquestions.
- [ ] Findings are documented with understandable tables or charts.
- [ ] `README.md` explains setup, design decisions, and how to run the queries.

**Start here:** Complete **Step 1 — Define business requirements**, then continue through schema design and normalization before writing SQL.
