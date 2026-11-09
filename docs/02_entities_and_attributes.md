# Step 2 — Identify Entities and Attributes

**Project:** Luxury Gym Management Database  
**Course:** CIS 3400  
**Database:** MySQL 8  
**Scope:** 6 tables · 34 attributes · 6 foreign-key relationships  
**Design approach:** Relational model with multi-location membership access

## 1. Purpose

This document defines the tables, attributes, data types, keys, and relationships for a simplified luxury gym database. The gym has multiple locations, and members with valid memberships may visit any active branch.

The design focuses on four business activities:

- Managing members and membership plans.
- Recording membership subscriptions and payment history.
- Tracking gym check-ins and check-outs at different branches.
- Analyzing membership preferences, attendance, and revenue.

**In scope:** `members`, `membership_plans`, `memberships`, `gym_visits`, `payments`, and `locations`.  
**Out of scope:** Free trials, fitness classes, amenities, reservations, employees, and payment-processing integrations.

### Notation

| Notation | Meaning |
|---|---|
| **PK** | Primary key: uniquely identifies a row. |
| **FK** | Foreign key: references a row in another table. |
| **UQ** | Unique: duplicate values are not allowed. |
| **Required** | `NOT NULL`: a value must be provided. |
| **Optional** | `NULL` is allowed. |
| **Auto-increment** | MySQL assigns the next identifier when a row is inserted. |

## 2. Entities and attributes

### Entity 1 — `members`

**Purpose:** Store the basic personal and contact information for each gym member.

| Attribute | MySQL data type | Key / constraint | Description |
|---|---|---|---|
| `member_id` | `INT` | **PK**, auto-increment | Unique member identifier. |
| `first_name` | `VARCHAR(60)` | Required | Member's first name. |
| `last_name` | `VARCHAR(60)` | Required | Member's last name. |
| `email` | `VARCHAR(255)` | Required, **UQ** | Member's unique email address. |
| `phone` | `VARCHAR(25)` | Optional | Contact phone number. |
| `date_of_birth` | `DATE` | Optional | Date of birth, used to calculate age groups. |
| `joining_date` | `DATE` | Required | Date the member joined the gym. |

**Key relationships:** One member can have many membership records and many gym visits.

### Entity 2 — `membership_plans`

**Purpose:** Describe the membership options offered by the gym.

| Attribute | MySQL data type | Key / constraint | Description |
|---|---|---|---|
| `plan_id` | `INT` | **PK**, auto-increment | Unique plan identifier. |
| `plan_name` | `VARCHAR(100)` | Required, **UQ** | Name of the membership plan. |
| `plan_level` | `VARCHAR(50)` | Required | Plan level, such as Basic or Premium. |
| `duration` | `INT` | Required | Plan duration **in months**. |
| `price` | `DECIMAL(10,2)` | Required | Listed price of the plan. |

**Key relationships:** One plan can be used by many membership records. `plan_name` is a normal unique attribute, **not** a foreign key.

### Entity 3 — `memberships`

**Purpose:** Connect a member with a membership plan and retain subscription history.

| Attribute | MySQL data type | Key / constraint | Description |
|---|---|---|---|
| `membership_id` | `INT` | **PK**, auto-increment | Unique membership record identifier. |
| `member_id` | `INT` | Required, **FK** → `members.member_id` | Member who holds the membership. |
| `plan_id` | `INT` | Required, **FK** → `membership_plans.plan_id` | Plan selected for this membership. |
| `start_date` | `DATE` | Required | Date the membership begins. |
| `end_date` | `DATE` | Optional | Date membership access ends, if known; also retained for canceled or expired memberships. |
| `created_at` | `DATETIME` | Required | Date and time the membership record was created. |

**Key relationships:** Each membership belongs to one member and one plan. A membership can have multiple payment records.

**Design note:** A `NULL` `end_date` does not by itself prove that a membership is active. Because there is no separate membership-status field, the project must document how it interprets open-ended memberships and plan duration before reporting active membership totals.

### Entity 4 — `gym_visits`

**Purpose:** Record which member visited which branch, including entry and exit times.

| Attribute | MySQL data type | Key / constraint | Description |
|---|---|---|---|
| `visit_id` | `INT` | **PK**, auto-increment | Unique gym visit identifier. |
| `member_id` | `INT` | Required, **FK** → `members.member_id` | Member who made the visit. |
| `location_id` | `INT` | Required, **FK** → `locations.location_id` | Branch visited. |
| `check_in_at` | `DATETIME` | Required | Date and time of entry. |
| `check_out_at` | `DATETIME` | Optional | Date and time of exit; remains `NULL` until the member checks out. |

**Key relationships:** Each visit belongs to one member and one location. A member and a location can each have many visits.

**Design note:** Visit duration can be calculated from `check_in_at` and `check_out_at` for completed visits. Incomplete visits should be handled separately in duration analysis.

### Entity 5 — `payments`

**Purpose:** Record payments for memberships and attribute payments to gym locations.

| Attribute | MySQL data type | Key / constraint | Description |
|---|---|---|---|
| `payment_id` | `INT` | **PK**, auto-increment | Unique payment identifier. |
| `membership_id` | `INT` | Required, **FK** → `memberships.membership_id` | Membership associated with the payment. |
| `location_id` | `INT` | Required, **FK** → `locations.location_id` | Location credited with the payment. |
| `amount` | `DECIMAL(10,2)` | Required | Recorded payment amount. |
| `paid_at` | `DATE` | Required | Date of the payment. |

**Key relationships:** Each payment belongs to one membership and one location. A membership or location can have many payments.

**Design note:** Members are linked to payments indirectly through `memberships`; a separate `member_id` column is not needed. Revenue by location means **payments attributed to that branch**, not necessarily payments made by visitors to that branch.

### Entity 6 — `locations`

**Purpose:** Store basic information for each gym branch.

| Attribute | MySQL data type | Key / constraint | Description |
|---|---|---|---|
| `location_id` | `INT` | **PK**, auto-increment | Unique branch identifier. |
| `location_name` | `VARCHAR(100)` | Required | Name of the gym branch. |
| `borough_name` | `VARCHAR(50)` | Required | Borough where the gym is located. |
| `opening_time` | `TIME` | Required | Standard opening time. |
| `closing_time` | `TIME` | Required | Standard closing time. |
| `is_active` | `BOOLEAN` | Required; default `TRUE` | Whether the branch is active. |

**Key relationships:** One location can have many gym visits and many payments.

**Design note:** The opening and closing times are simplified standard hours; this schema does not track separate schedules for weekdays, weekends, or holidays.

## 3. Primary keys and foreign keys

### Primary keys

| Table | Primary key |
|---|---|
| `members` | `member_id` |
| `membership_plans` | `plan_id` |
| `memberships` | `membership_id` |
| `gym_visits` | `visit_id` |
| `payments` | `payment_id` |
| `locations` | `location_id` |

### Foreign keys and relationships

All **six relationships** are **one-to-many (1:N)**. The foreign-key columns are required (`NOT NULL`).

| Parent table (one) | Child table (many) | Foreign key in child |
|---|---|---|
| `members` | `memberships` | `memberships.member_id` |
| `membership_plans` | `memberships` | `memberships.plan_id` |
| `members` | `gym_visits` | `gym_visits.member_id` |
| `locations` | `gym_visits` | `gym_visits.location_id` |
| `memberships` | `payments` | `payments.membership_id` |
| `locations` | `payments` | `payments.location_id` |

A parent row can have **zero or many** corresponding child rows, but each child row references **exactly one** parent in each required relationship.

## 4. Basic business rules

1. Each table has a unique primary key.
2. A member's email must be unique.
3. Each membership connects one existing member to one existing membership plan.
4. A member may have several membership records over time.
5. Members with valid memberships can visit any active gym location; subscriptions are not restricted to one branch.
6. Every gym visit records both the member and the location visited.
7. `check_out_at` may be `NULL` while a visit is in progress.
8. `end_date` may be `NULL` when the membership end date is not known or recorded.
9. Every payment is associated with one membership and one location.
10. Past memberships, visits, and payments are retained for reporting.

### Validations to consider during MySQL implementation

These checks are **proposed rules for Step 5**, not additional attributes or tables:

- `membership_plans.duration > 0`
- `membership_plans.price >= 0`
- `payments.amount > 0`
- `memberships.end_date >= memberships.start_date` when `end_date` is not `NULL`
- `gym_visits.check_out_at >= gym_visits.check_in_at` when `check_out_at` is not `NULL`
- Membership eligibility and active-branch access must be checked by queries or application logic; foreign keys alone do not enforce them.

## 5. Support for analytical questions

| Business question | Tables used |
|---|---|
| Which locations, days, and hours are busiest? | `gym_visits`, `locations` |
| Which membership plans are selected most often? | `memberships`, `membership_plans` |
| How do payment totals compare across branches and boroughs? | `payments`, `locations` |
| How does gym attendance vary by member age group? | `members`, `gym_visits` |
| How frequently do members visit and how long do they stay? | `members`, `gym_visits` |

## 6. Summary and next step

| Design item | Total |
|---|---:|
| Entities (tables) | **6** |
| Attributes (columns) | **34** |
| Primary keys | **6** |
| Foreign keys | **6** |
| One-to-many relationships | **6** |

**Next step — Step 3:** Use these exact six tables and six foreign-key relationships to update `diagrams/03_gym_database.dbml` and generate the Crow's Foot ER diagram. After that, review the schema for normalization (1NF, 2NF, 3NF) before writing MySQL `CREATE TABLE` statements.
