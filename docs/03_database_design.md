# Step 3 — Logical ER Diagram and DBML Design

**Project:** CIS 3400 — Luxury Gym Management Database  
**Database target:** MySQL 8  
**Data model:** Multi-location, network-wide membership access  
**Source of truth:** `03_gym_database.dbml`  
**Visual:** `03_gym_erd.png` (also provided as `03_gym_erd.svg`)  
**Status:** Step 3 logical design; tables have **not** yet been implemented in MySQL.

## 1. Goal and result

Translate the Step 2 data dictionary into an editable, relational schema and visualize it in Crow's Foot notation. The current design contains **12 tables, 97 attributes, and 18 foreign-key relationships**. DBML records primary keys, foreign keys, required/optional fields, uniqueness, indexes, and row-level checks.

The model follows these policies:

- A valid paid membership gives access to **any active branch**, irrespective of the member's home location or membership's sales location.
- A valid free trial also permits network-wide gym access in this classroom version. The registration location is used for reporting only.
- Class or amenity access requires the corresponding `includes_classes` or `includes_amenities` entitlement and a valid subscription/trial.
- Branch-specific facts store a location directly; records whose parent identifies the location do not duplicate it.
- `membership_plans` and `class_types` are shared catalogs, not per-location catalogs.

## 2. Entity inventory

| ID | Table | Role |
|---|---|---|
| E01 | `locations` | Physical branches and local time zone |
| E02 | `members` | Global member profiles and optional preferred branch |
| E03 | `membership_plans` | Shared plan and benefit catalog |
| E04 | `memberships` | Purchased terms, renewals, and sales attribution |
| E05 | `free_trials` | Trial terms and registration attribution |
| E06 | `gym_visits` | Actual member check-ins by branch |
| E07 | `amenities` | Branch-specific bookable facilities |
| E08 | `amenity_reservations` | Reservations for individual amenities |
| E09 | `class_types` | Shared class definitions |
| E10 | `class_sessions` | Timed classes at specific branches |
| E11 | `class_enrollments` | Members booked into sessions |
| E12 | `payments` | Membership payment attempts and receipts |

Every table has an auto-generated `BIGINT UNSIGNED` primary key.

## 3. Relationships: Crow's Foot cardinalities

In the DBML, `Ref: child.foreign_key > parent.primary_key` represents a many-to-one relationship: **each child references one parent**, and **one parent can have zero or many children**. `>?` marks a *nullable/optional* parent reference. Each column's `not null` setting agrees with that optionality.

| Parent (one) | Child (many) | Child FK | Required? |
|---|---|---|---|
| `locations` | `members` | `home_location_id` | No |
| `locations` | `memberships` | `sold_at_location_id` | No |
| `locations` | `free_trials` | `registered_at_location_id` | Yes |
| `locations` | `gym_visits` | `location_id` | Yes |
| `locations` | `amenities` | `location_id` | Yes |
| `locations` | `class_sessions` | `location_id` | Yes |
| `locations` | `payments` | `collected_at_location_id` | No |
| `members` | `memberships` | `member_id` | Yes |
| `membership_plans` | `memberships` | `plan_id` | Yes |
| `memberships` | `memberships` | `renewed_from_membership_id` | No |
| `members` | `free_trials` | `member_id` | Yes |
| `members` | `gym_visits` | `member_id` | Yes |
| `members` | `amenity_reservations` | `member_id` | Yes |
| `amenities` | `amenity_reservations` | `amenity_id` | Yes |
| `class_types` | `class_sessions` | `class_type_id` | Yes |
| `members` | `class_enrollments` | `member_id` | Yes |
| `class_sessions` | `class_enrollments` | `class_session_id` | Yes |
| `memberships` | `payments` | `membership_id` | Yes |

*Relationship note:* The **18** FKs include **seven** FKs from child tables to `locations`, plus the membership self-reference.

## 4. Many-to-many cases resolved by existing tables

- `members` ↔ `class_sessions` via `class_enrollments`.
- `members` ↔ `amenities` via `amenity_reservations`.
- `members` ↔ `membership_plans` via `memberships` (purchase history).
- `members` ↔ `locations` via `gym_visits` (actual check-ins).

A `membership_location_access` table is **not** necessary because network-wide access is a global business rule. Adding location restrictions later would require changing the model.

## 5. Integrity rules represented in DBML

**Keys and uniqueness**

- Primary key for each of the 12 tables.
- All 18 relationships are explicit foreign keys.
- Global uniqueness: `members.email`, `locations.location_name`, `membership_plans.plan_name`, `class_types.class_name`.
- Composite uniqueness: `amenities(location_id, amenity_name)` and `class_enrollments(member_id, class_session_id)`.
- `payments.transaction_reference` is unique when provided; multiple `NULL` values are allowed by MySQL.

**Checks (subject to SQL export review)**

- Membership/trial `end_date >= start_date`.
- Visit check-out does not precede check-in.
- Session and amenity reservation end times follow start times.
- Capacities and booked guest counts are greater than zero.
- Plan fees and payment amounts are nonnegative.
- Controlled status values for memberships, trials, classes, reservations, enrollments, and payments.

**Preservation**

- Foreign keys are configured with `delete: restrict` to prevent accidental loss of related historical records. Close/deactivate records instead of deleting referenced data.
- Past payment amounts are stored in `payments.amount` so that changing plan prices will not rewrite history.

## 6. Important rules *not* enforced by basic PK/FK/CHECK alone

The database schema is only part of the application workflow. During later implementation, these require validated transactions, triggers, stored procedures, or application logic:

1. **Check-in eligibility:** `location.is_active = true` and paid membership/trial status is active with the branch-local event date inside its eligible term.
2. **Class/amenity eligibility:** class or amenity flag on the valid plan/trial; scheduled session/amenity belongs to an active location.
3. **No overlapping eligible paid memberships** for one member.
4. **No multiple simultaneously open gym visits** for one member across all locations.
5. **Capacity-safe class booking** under concurrent enrollments.
6. **Time-overlap-safe amenity reservations** based on sum of `guest_count` for the particular facility.
7. **Prevent overlapping class sessions in a single room** at one location.
8. **Valid payment lifecycle:** e.g. `completed` payments should have `paid_at`; refunds need clear reporting logic.

### Cancellation policy for classroom exercises

Treat a membership with `membership_status = 'canceled'` as **ineligible from the cancellation's effective time**. If a cancellation is scheduled for end of term, keep the membership active through its paid-through date and then change the status. This is an implementation convention to document explicitly in the SQL phase.

### Time-zone convention

Store event `DATETIME` values in UTC. Convert to `locations.time_zone` for local check-in day/hour reports and for evaluating **date-only** membership/trial entitlement windows. `opening_time` and `closing_time` are standard **local** times; weekday and holiday schedules are outside the current scope. In MySQL, named-zone conversion using `CONVERT_TZ()` may require loaded time-zone tables.

## 7. How to use the DBML file in dbdiagram.io

1. Open **https://dbdiagram.io** and create/open a diagram.
2. Open `03_gym_database.dbml` in any text editor, copy the entire file, and paste into the left-side DBML editor.
3. Confirm that **12 tables** appear and the lines show 18 foreign-key relationships. Rearrange tables for readability.
4. Save the project; export the diagram as **PNG/SVG/PDF** if desired. Use the site's **Export → SQL → MySQL** option when ready for implementation.
5. Keep the DBML file as the authoritative design in GitHub so edits remain reviewable in commits.

The provided `03_gym_erd.png` was **rendered locally** from the same source file and includes Crow's Foot cardinality markers; it is not a screenshot or direct dbdiagram.io export. Regenerating it in dbdiagram.io may produce a different visual layout, but it should reflect the same logical schema.

**Official references:**

- DBML syntax: https://dbml.dbdiagram.io/docs/
- dbdiagram editor/export: https://docs.dbdiagram.io/basic-editing-experience/
- Relationship cardinality: https://docs.dbdiagram.io/relationships/

## 8. Suggested GitHub structure

```text
cis3400-gym-database/
├── docs/
│   ├── 01_business_requirements.md
│   ├── 02_entities_and_attributes.md
│   └── 03_database_design.md
├── diagrams/
│   ├── 03_gym_database.dbml
│   ├── 03_gym_erd.png
│   └── 03_gym_erd.svg
└── sql/
    └── create_tables.sql   # created in a later implementation step
```

Suggested commit message:

```text
Add multi-location gym DBML schema and Crow's Foot ER diagram
```

## 9. Review before Step 4 (normalization)

- [x] All 12 Step 2 entities represented.
- [x] Original Step 2 attributes preserved, including optional location associations.
- [x] All 18 foreign keys defined, including the self-reference for renewals.
- [x] Direct versus derived location references modeled consistently.
- [x] Many-to-many relationships represented using associative tables.
- [x] Unique, required, indexing, and row-level checks proposed.
- [ ] Run DBML through dbdiagram.io to inspect any export warnings and the visual layout.
- [ ] Evaluate 1NF, 2NF, 3NF and any dependency issues in **Step 4**.
- [ ] Review generated MySQL `CREATE TABLE` DDL and transaction requirements during implementation.
