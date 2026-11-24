# Step 4 — Database Normalization (UNF → 1NF → 2NF → 3NF)

**Project:** CIS 3400 — Luxury Gym Management Database  
**Database:** MySQL 8, `luxury_gym`  
**Final design:** 6 tables, 34 columns, 6 primary keys, and 6 foreign keys  
**Implementation reviewed:** [`sql/00_create_database.sql`](../sql/00_create_database.sql)

## 1. Purpose and approach

Normalization organizes data so that each fact is stored in the appropriate place. For this project, the goal is to support members, membership plans, subscriptions, gym visits, payments, and multiple gym branches without unnecessarily repeating information.

This document **reconstructs the design reasoning** from a possible unnormalized record to the **six tables actually implemented**. The early tables below are *illustrative teaching examples*, not tables that previously existed in the repository. The final schema, column names, and constraints are taken from `sql/00_create_database.sql`, with supporting definitions in [`02_entities_and_attributes.md`](02_entities_and_attributes.md), [`03_database_design.md`](03_database_design.md), and [`01_Business_Requirements.md`](01_Business_Requirements.md).

Two important project rules guide the design:

- Members with a valid membership may visit **any active location**. A membership is not assigned to a single home branch.
- A payment is **credited to a location**. This does not necessarily mean the member visited that location on the payment date.

The target is **Third Normal Form (3NF)** while keeping the approved six-table scope.

## 2. Unnormalized form (UNF): imagine all information in one record

A first attempt to track gym activity might put a member, their plan, their membership, and lists of related visits and payments into one record:

```text
member_id: 1
first_name: Example
last_name: Member
email: example@example.com
membership_id: 10
plan_id: 2
plan_name: Plus Monthly
plan_level: Plus
duration: 1
price: 125.00
start_date: 2026-11-01

visits:
  - {visit_id: 101, location_id: 1, check_in_at: ..., check_out_at: ...}
  - {visit_id: 102, location_id: 2, check_in_at: ..., check_out_at: ...}

payments:
  - {payment_id: 201, location_id: 1, amount: 125.00, paid_at: ...}
  - {payment_id: 202, location_id: 1, amount: 125.00, paid_at: ...}
```

*Illustrative values only; this is not the project's sample dataset.*

This structure is **unnormalized** because `visits` and `payments` are repeating groups rather than individual relational rows. It also mixes facts about different entities.

Problems include:

- **Update anomaly:** changing a member's email or a plan's description could require changes in multiple records.
- **Insertion anomaly:** a new plan or branch would be difficult to record before a member uses it.
- **Deletion anomaly:** deleting the last visit might accidentally remove the only copy of the member's details.
- **Unnecessary duplication:** the same member, plan, and branch data could appear repeatedly.

A further problem: visits and payments are **independent events**. Placing them in one combined flat table can create multiple visit–payment combinations for the same membership. A member with two visits and two payments could produce four rows even though only two of each event actually occurred.

## 3. First Normal Form (1NF): store one value per field

**1NF requires** single-valued (atomic) attributes, no repeating groups, and individually identifiable rows.

We replace lists such as `visits = [visit 101, visit 102]` with **separate visit records**, and lists of payments with **separate payment records**. Each real-world occurrence has its own identifier:

| Fact being recorded | Individual row identifier | Example attributes |
|---|---|---|
| Member | `member_id` | `first_name`, `last_name`, `email` |
| Plan | `plan_id` | `plan_name`, `duration`, `price` |
| Subscription | `membership_id` | `member_id`, `plan_id`, `start_date` |
| Gym entry | `visit_id` | `member_id`, `location_id`, `check_in_at` |
| Payment | `payment_id` | `membership_id`, `location_id`, `amount` |
| Branch | `location_id` | `location_name`, `borough_name` |

This shows the kinds of records the gym needs; it does **not** mean that identifying six types of records by itself proves 2NF or 3NF.

In the implemented schema, dates, times, prices, IDs, and names are stored as individual column values. Multiple gym visits are represented by multiple rows in `gym_visits`, and multiple payments by multiple rows in `payments`. There are no comma-separated visit IDs, plan lists, or repeating visit/payment columns.

**1NF result:** Every final table has its own primary key, each field stores a single value, and repeated events are separate rows. Some duplication would still be possible if descriptive details were copied between tables, so further normalization is needed.

## 4. Second Normal Form (2NF): remove partial dependencies

**2NF requires 1NF and no partial dependency of a non-prime attribute on only part of a candidate key.** Partial dependencies matter when an identifying key contains multiple attributes.

Consider a *hypothetical* enrollment table identified by the combination `(member_id, plan_id, start_date)`:

| member_id | plan_id | start_date | member_email | plan_name |
|---|---|---|---|---|
| 1 | 2 | 2026-11-01 | example@example.com | Plus Monthly |
| 2 | 2 | 2026-11-02 | another@example.com | Plus Monthly |

In this example:

- `member_id → member_email`: email depends only on `member_id`.
- `plan_id → plan_name`: plan name depends only on `plan_id`.
- Neither descriptive attribute depends on the **whole** hypothetical composite key.

Those are partial dependencies. The corrected design separates:

1. `members` — member information stored once, keyed by `member_id`.
2. `membership_plans` — plan information stored once, keyed by `plan_id`.
3. `memberships` — individual subscriptions, connecting a member to a plan and storing subscription-specific dates.

The **actual project** uses `membership_id` as a single-column primary key rather than relying on the example's composite identifier. This is suitable because members can purchase plans repeatedly over time and the database retains subscription history.

The same principle applies to gym activity: member information stays in `members`, branch information stays in `locations`, and an individual visit holds only the relevant identifiers and timestamps.

**2NF result:** The six implemented tables use single-column primary keys, and the only declared additional unique keys (`members.email` and `membership_plans.plan_name`) are also single-column keys. Based on the documented dependencies, no non-key attribute depends on just part of a composite candidate key. A surrogate primary key alone is not proof of 2NF; the dependencies must also be checked.

## 5. Third Normal Form (3NF): remove transitive dependencies

**3NF requires 2NF and, for every nontrivial functional dependency `X → A`, either `X` is a superkey or `A` is a prime attribute.** In practical terms for this project, we avoid storing descriptive facts that belong to a different entity.

Imagine a payment table containing all these columns:

| payment_id | membership_id | member_email | plan_name | location_id | borough_name | amount |
|---|---|---|---|---|---|---|
| 201 | 10 | example@example.com | Plus Monthly | 1 | Queens | 125.00 |

This table repeats information that can be determined through other records. For example:

- `payment_id → membership_id → member_id`: the member is determined by the payment's linked subscription.
- `payment_id → location_id → borough_name`: the borough is determined by the credited branch.
- `payment_id → membership_id → plan_id → plan_name`: the plan's name is determined by the membership's referenced plan.

Keeping `member_email`, `plan_name`, or `borough_name` directly in every payment would cause redundant updates.

Instead, the implemented **`payments`** table contains only:

```text
payment_id (PK)
membership_id (FK → memberships.membership_id)
location_id   (FK → locations.location_id)
amount
paid_at
```

Related details are obtained when needed with SQL `JOIN` operations.

The same rule determines where the other information belongs:

- Member names and contact details belong to `members`, not `memberships` or `gym_visits`.
- Plan descriptions, levels, durations, and listed prices belong to `membership_plans`, not `memberships`.
- Branch names, boroughs, hours, and active status belong to `locations`, not `gym_visits` or `payments`.
- Start/end dates and creation timestamps belong to the specific `memberships` record.
- Check-in and check-out times belong to the specific `gym_visits` record.
- Actual payment amounts and dates belong to `payments`, not `membership_plans`.

**3NF result:** Under the business rules documented for this project, each non-key attribute in the final tables describes the entity identified by that table's key, rather than a separate entity reached through another non-key attribute.

## 6. Final normalized schema: the exact six implemented tables

The following columns match [`sql/00_create_database.sql`](../sql/00_create_database.sql).

| Table | Primary key | Remaining columns | Purpose |
|---|---|---|---|
| `members` (7 columns) | `member_id` | `first_name`, `last_name`, `email`, `phone`, `date_of_birth`, `joining_date` | One record for each gym member |
| `membership_plans` (5) | `plan_id` | `plan_name`, `plan_level`, `duration`, `price` | Reusable definitions of available plans |
| `locations` (6) | `location_id` | `location_name`, `borough_name`, `opening_time`, `closing_time`, `is_active` | One record for each gym branch |
| `memberships` (6) | `membership_id` | `member_id` (FK), `plan_id` (FK), `start_date`, `end_date`, `created_at` | A member's subscription to a plan, including history |
| `gym_visits` (5) | `visit_id` | `member_id` (FK), `location_id` (FK), `check_in_at`, `check_out_at` | One visit at one specific branch |
| `payments` (5) | `payment_id` | `membership_id` (FK), `location_id` (FK), `amount`, `paid_at` | One recorded payment credited to a branch |

**Total: 6 tables and 34 columns.** Each table has an auto-incrementing integer primary key.

### Functional dependencies supporting the design

For the primary-key dependencies shown below, the key uniquely determines the remaining attributes of its own table:

```text
member_id     → first_name, last_name, email, phone,
                date_of_birth, joining_date

plan_id       → plan_name, plan_level, duration, price

location_id   → location_name, borough_name, opening_time,
                closing_time, is_active

membership_id → member_id, plan_id, start_date, end_date, created_at

visit_id      → member_id, location_id, check_in_at, check_out_at

payment_id    → membership_id, location_id, amount, paid_at
```

`members.email` and `membership_plans.plan_name` are also unique, so each serves as an alternative single-column identifier for its respective table.

## 7. Foreign keys: how the separate tables work together

Normalization does not mean losing the connections between records. The final design maintains exactly **six one-to-many relationships**:

| Parent (one) | Child (many) | Foreign key |
|---|---|---|
| `members` | `memberships` | `memberships.member_id` |
| `membership_plans` | `memberships` | `memberships.plan_id` |
| `members` | `gym_visits` | `gym_visits.member_id` |
| `locations` | `gym_visits` | `gym_visits.location_id` |
| `memberships` | `payments` | `payments.membership_id` |
| `locations` | `payments` | `payments.location_id` |

Each child-side foreign key is `NOT NULL`. A parent can have zero or many corresponding child records.

**Why are both `gym_visits.location_id` and `payments.location_id` needed?** They record *different facts*: the branch actually visited versus the branch credited with a payment. Neither should be inferred from the other. Likewise, `memberships` does not contain `location_id`, because the plan allows visits across active branches.

See [the logical ER design](03_database_design.md) for the Crow's Foot relationships.

## 8. Integrity rules and important distinctions

The SQL implementation reinforces the design with:

- `UNIQUE` constraints on `members.email` and `membership_plans.plan_name`.
- `NOT NULL` requirements for essential values and all six foreign keys.
- `CHECK (duration > 0)` and `CHECK (price > 0)` on `membership_plans`.
- `CHECK (amount > 0)` on `payments`.
- Checks preventing `memberships.end_date` from preceding `start_date` and `gym_visits.check_out_at` from preceding `check_in_at` when the optional end values are present.
- A default of `TRUE` for `locations.is_active`.

These constraints support **data integrity**; they do not, by themselves, establish a normal form.

Several intentionally distinct fields also matter:

- **`membership_plans.price` vs. `payments.amount`:** `price` is a plan's listed price; `amount` is what a payment record actually shows. They are not assumed to be identical, and `amount` is the field to sum for recorded revenue.
- **`membership_plans.duration` vs. `memberships.end_date`:** `duration` is the standard duration in months; `end_date` is an optional recorded end date for a particular subscription. This design allows recorded endings to differ, such as after cancellation. If business policy were changed so that every `end_date` had to be calculated mechanically, that rule and any resulting redundancy should be revisited.
- **`gym_visits.check_out_at`:** may be `NULL` until a visit ends; a visit's length can be calculated from the two timestamps rather than stored as a second, redundant duration field.
- **`members.date_of_birth`:** member age is calculated when needed, so age does not become a potentially stale stored column.
- **Membership status:** `memberships` has no stored status column. A `NULL` `end_date` does not automatically establish that a membership is currently valid; eligibility requires agreed business logic.

The foreign keys ensure referenced rows exist. They do **not** independently enforce active-membership eligibility or verify that a visited branch is active; those rules require additional queries or application logic.

## 9. Example: recover related information without duplicating it

Although data is separated into normalized tables, a report can combine it again:

```sql
USE luxury_gym;

SELECT
    m.member_id,
    m.first_name,
    m.last_name,
    mp.plan_name,
    ms.start_date,
    ms.end_date
FROM memberships AS ms
JOIN members AS m
    ON m.member_id = ms.member_id
JOIN membership_plans AS mp
    ON mp.plan_id = ms.plan_id;
```

This report displays member and plan information without copying `first_name` or `plan_name` into the `memberships` table.

For revenue by borough, a query can join `payments` to `locations` using `payments.location_id` and group by `locations.borough_name`; the borough does not need to be repeated in every payment row.

## 10. Normalization review of all six tables

| Table | 1NF | 2NF | 3NF | Reason |
|---|---|---|---|---|
| `members` | Yes | Yes | Yes | Atomic member fields; descriptive information depends on the member key |
| `membership_plans` | Yes | Yes | Yes | Plan attributes describe the plan identified by `plan_id` |
| `locations` | Yes | Yes | Yes | Branch details depend on `location_id` rather than event records |
| `memberships` | Yes | Yes | Yes* | Subscription facts are stored here; member and plan descriptions remain in their parent tables |
| `gym_visits` | Yes | Yes | Yes | Each visit stores its own member, branch, and timestamps |
| `payments` | Yes | Yes | Yes | Payment-specific facts stay here; member, plan, and branch descriptions are accessed through foreign keys |

*The 3NF assessment assumes the documented interpretation of `end_date` as a recorded subscription-specific value, not an always-recomputed copy of plan duration. More generally, normalization conclusions depend on the actual functional dependencies and business rules.*

### Conclusion

The final six-table schema is **consistent with Third Normal Form (3NF) under the project's documented business assumptions**. The normalization process separates:

1. **People** into `members`.
2. **Plan definitions** into `membership_plans`.
3. **Subscription events** into `memberships`.
4. **Branch definitions** into `locations`.
5. **Attendance events** into `gym_visits`.
6. **Financial events** into `payments`.

This structure minimizes repeated descriptions, prevents common insertion/update/deletion anomalies, preserves membership and transaction history, and supports analytical reporting with SQL joins.

**No additional tables or column changes are required for this normalization review.** The design remains aligned with the six-table scope defined in the project's requirements and implemented in `sql/00_create_database.sql`.
