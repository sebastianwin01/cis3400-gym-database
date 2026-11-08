# Step 2 — Identify Entities and Attributes

**Project:** CIS 3400 — Luxury Gym Management Database  
**Database:** MySQL 8  
**Design stage:** Conceptual-to-logical data model (before ER diagram and `CREATE TABLE` statements)  
**Reference:** `luxury_gym_business_requirements.md`  
**Scope:** The 11 core entities agreed in Step 1; single fictional gym location.

## 1. Objective

Identify the business entities that need to be stored in the database, the attributes that describe them, and the proposed keys that will connect their records. This is a **proposed data dictionary**, not final SQL DDL: data types, constraints, and optionality should be confirmed when the ER diagram and database schema are reviewed.

**Notation:** **PK** = primary key; **FK** = foreign key; **UQ** = unique; **Required** = a value must be provided; **Optional** = `NULL` is permitted. Proposed identifiers use `BIGINT UNSIGNED` and are intended to be auto-generated.

## 2. Entity and attribute dictionary

### E01 — `members`

**Purpose:** Store one profile for each gym member or free-trial participant. A person's subscription status is kept in `memberships`, rather than duplicated here.

| Attribute | Proposed MySQL type | Key / required? | Meaning |
|---|---|---|---|
| `member_id` | `BIGINT UNSIGNED` | **PK**, required | Unique member identifier. |
| `first_name` | `VARCHAR(60)` | Required | Member's given name. |
| `last_name` | `VARCHAR(60)` | Required | Member's surname. |
| `email` | `VARCHAR(255)` | **UQ**, required | Contact email; unique per profile. |
| `phone` | `VARCHAR(25)` | Optional | Phone number. |
| `date_of_birth` | `DATE` | Required | Enables age-group analyses; age itself is calculated rather than stored. |
| `joined_at` | `DATETIME` | Required | Date and time profile was created. |

**Notes:** Member records should be retained for links to historical bookings, payments, and visits. If the real gym permits shared contact emails, revisit the email uniqueness rule.

### E02 — `membership_plans`

**Purpose:** Define the subscription products the gym sells.

| Attribute | Proposed MySQL type | Key / required? | Meaning |
|---|---|---|---|
| `plan_id` | `BIGINT UNSIGNED` | **PK**, required | Unique plan identifier. |
| `plan_name` | `VARCHAR(100)` | **UQ**, required | Plan label, e.g., Standard, Premium, Elite. |
| `description` | `TEXT` | Optional | Human-readable description of included benefits. |
| `plan_price` | `DECIMAL(10,2)` | Required | Price charged for one full plan term; must be nonnegative. |
| `duration_months` | `SMALLINT UNSIGNED` | Required | Length of the plan term in calendar months; must be greater than zero. |
| `includes_classes` | `BOOLEAN` (`TINYINT(1)`) | Required | Whether plan permits fitness-class bookings in general. |
| `includes_amenities` | `BOOLEAN` (`TINYINT(1)`) | Required | Whether plan permits amenity bookings in general. |
| `is_active` | `BOOLEAN` (`TINYINT(1)`) | Required | Whether this plan is currently available for new purchases. |

**Notes:** `plan_price` refers to the *term price*, not necessarily a monthly fee. The two inclusion flags represent broad entitlements only; granular per-amenity/per-class rights would require additional mapping tables in a future version. Price changes should not retroactively alter historical payment amounts.

### E03 — `memberships`

**Purpose:** Store each member's purchased subscription, dates, status, and renewal lineage. Keep old records rather than overwriting them on renewal.

| Attribute | Proposed MySQL type | Key / required? | Meaning |
|---|---|---|---|
| `membership_id` | `BIGINT UNSIGNED` | **PK**, required | Unique subscription instance. |
| `member_id` | `BIGINT UNSIGNED` | **FK** → `members.member_id`, required | Person who owns the subscription. |
| `plan_id` | `BIGINT UNSIGNED` | **FK** → `membership_plans.plan_id`, required | Plan purchased. |
| `start_date` | `DATE` | Required | First eligible day of the subscription. |
| `end_date` | `DATE` | Required | Last eligible day of the subscription, inclusive. |
| `membership_status` | `VARCHAR(20)` | Required | Proposed values: `pending`, `active`, `expired`, `canceled`. |
| `renewed_from_membership_id` | `BIGINT UNSIGNED` | Optional **self-FK** → `memberships.membership_id` | Earlier subscription that this one renews. |
| `canceled_at` | `DATETIME` | Optional | When a cancellation was recorded, if applicable. |
| `created_at` | `DATETIME` | Required | When this subscription record was created. |

**Notes:** `end_date >= start_date`. Decide during Step 3 whether cancellation ends access immediately or at the paid-through date. A member can have multiple historical memberships, but any overlapping *eligible* memberships must be handled by an explicit policy to avoid ambiguous plan attribution.

### E04 — `free_trials`

**Purpose:** Store free-trial offers and measure whether participants later become paying members.

| Attribute | Proposed MySQL type | Key / required? | Meaning |
|---|---|---|---|
| `trial_id` | `BIGINT UNSIGNED` | **PK**, required | Unique free-trial identifier. |
| `member_id` | `BIGINT UNSIGNED` | **FK** → `members.member_id`, required | Trial participant. |
| `start_date` | `DATE` | Required | First eligible trial day. |
| `end_date` | `DATE` | Required | Last eligible trial day, inclusive. |
| `trial_status` | `VARCHAR(20)` | Required | Proposed values: `scheduled`, `active`, `completed`, `canceled`. |
| `includes_classes` | `BOOLEAN` (`TINYINT(1)`) | Required | Trial grants general fitness-class access. |
| `includes_amenities` | `BOOLEAN` (`TINYINT(1)`) | Required | Trial grants general amenity access. |
| `created_at` | `DATETIME` | Required | When the trial was registered. |

**Notes:** `end_date >= start_date`. Do **not** store a separate `converted_to_member` boolean: conversion is determined from later records in `memberships`, using the same `member_id`. A conversion within 30 days of trial end means a paid subscription starts after the trial ends and no later than 30 days afterward (final business definition subject to confirmation).

### E05 — `gym_visits`

**Purpose:** Record attendance at the gym and support peak-use and demographic analyses.

| Attribute | Proposed MySQL type | Key / required? | Meaning |
|---|---|---|---|
| `visit_id` | `BIGINT UNSIGNED` | **PK**, required | Unique visit identifier. |
| `member_id` | `BIGINT UNSIGNED` | **FK** → `members.member_id`, required | Person who checked in. |
| `check_in_at` | `DATETIME` | Required | Time member entered the gym. |
| `check_out_at` | `DATETIME` | Optional | Time member exited; `NULL` when not recorded yet. |

**Notes:** `check_out_at IS NULL OR check_out_at >= check_in_at`. Access must be validated against a valid membership or trial *at check-in time*. For AQ-01, attribute a visit to the eligible membership covering the visit timestamp; the overlapping-membership policy must prevent ambiguity.

### E06 — `amenities`

**Purpose:** Catalog premium facilities members can use or reserve.

| Attribute | Proposed MySQL type | Key / required? | Meaning |
|---|---|---|---|
| `amenity_id` | `BIGINT UNSIGNED` | **PK**, required | Unique amenity identifier. |
| `amenity_name` | `VARCHAR(100)` | **UQ**, required | Facility name, e.g., Sauna, Pool, Spa Room. |
| `description` | `TEXT` | Optional | Facility details or usage rules. |
| `capacity` | `SMALLINT UNSIGNED` | Required | Maximum simultaneous reserved guests; must be positive. |
| `requires_reservation` | `BOOLEAN` (`TINYINT(1)`) | Required | Whether advance booking is required. |
| `is_active` | `BOOLEAN` (`TINYINT(1)`) | Required | Whether amenity is offered and bookable. |

**Notes:** For the 11-table version, each amenity row represents one bookable facility. If there are multiple identical rooms or equipment units that need separate availability, model each as a distinct amenity row or introduce a resource table later.

### E07 — `amenity_reservations`

**Purpose:** Record who reserved an amenity, for which time window, and whether the reservation was used.

| Attribute | Proposed MySQL type | Key / required? | Meaning |
|---|---|---|---|
| `reservation_id` | `BIGINT UNSIGNED` | **PK**, required | Unique reservation identifier. |
| `member_id` | `BIGINT UNSIGNED` | **FK** → `members.member_id`, required | Member making the booking. |
| `amenity_id` | `BIGINT UNSIGNED` | **FK** → `amenities.amenity_id`, required | Booked facility. |
| `start_at` | `DATETIME` | Required | Reserved start time. |
| `end_at` | `DATETIME` | Required | Reserved end time. |
| `guest_count` | `SMALLINT UNSIGNED` | Required | Number of reserved spots; default 1. |
| `reservation_status` | `VARCHAR(20)` | Required | Proposed values: `booked`, `canceled`, `completed`, `no_show`. |
| `booked_at` | `DATETIME` | Required | When the booking was made. |
| `actual_start_at` | `DATETIME` | Optional | Actual start of amenity usage, if tracked. |
| `actual_end_at` | `DATETIME` | Optional | Actual end of amenity usage, if tracked. |

**Notes:** Require `end_at > start_at`, `guest_count > 0`; actual end cannot precede actual start. For overlapping, non-canceled reservations, the sum of `guest_count` must not exceed `amenities.capacity`. This is a **cross-row time-overlap rule** that needs transactional booking logic, not just a column `CHECK` constraint. Reservation eligibility also depends on an active membership/trial with amenity access.

### E08 — `class_types`

**Purpose:** Describe the kinds of fitness classes available independently from any scheduled occurrence.

| Attribute | Proposed MySQL type | Key / required? | Meaning |
|---|---|---|---|
| `class_type_id` | `BIGINT UNSIGNED` | **PK**, required | Unique type identifier. |
| `class_name` | `VARCHAR(100)` | **UQ**, required | Class category, e.g., Yoga, Pilates, Cycling. |
| `description` | `TEXT` | Optional | Information about the class. |
| `default_duration_minutes` | `SMALLINT UNSIGNED` | Required | Typical session length; must be positive. |
| `difficulty_level` | `VARCHAR(20)` | Optional | Proposed values: `beginner`, `intermediate`, `advanced`, `all_levels`. |
| `is_active` | `BOOLEAN` (`TINYINT(1)`) | Required | Whether the class type is currently offered. |

**Notes:** A class type is reusable across many scheduled sessions. If a particular session differs from its typical duration, the session's actual start and end times govern.

### E09 — `class_sessions`

**Purpose:** Store each dated and timed occurrence of a fitness class.

| Attribute | Proposed MySQL type | Key / required? | Meaning |
|---|---|---|---|
| `class_session_id` | `BIGINT UNSIGNED` | **PK**, required | Unique scheduled session identifier. |
| `class_type_id` | `BIGINT UNSIGNED` | **FK** → `class_types.class_type_id`, required | Type of class being held. |
| `starts_at` | `DATETIME` | Required | Scheduled start time. |
| `ends_at` | `DATETIME` | Required | Scheduled end time. |
| `max_capacity` | `SMALLINT UNSIGNED` | Required | Maximum number of enrolled attendees; must be positive. |
| `room_name` | `VARCHAR(80)` | Optional | Where the class takes place. |
| `session_status` | `VARCHAR(20)` | Required | Proposed values: `scheduled`, `completed`, `canceled`. |

**Notes:** Require `ends_at > starts_at`. Capacity is applied to active booked enrollments, not canceled records. Trainer/staff management is excluded from the current 11-entity scope; add a `trainers` table in a future iteration if instructor assignments become a business requirement.

### E10 — `class_enrollments`

**Purpose:** Represent a member's booking for one scheduled fitness session and the booking outcome.

| Attribute | Proposed MySQL type | Key / required? | Meaning |
|---|---|---|---|
| `enrollment_id` | `BIGINT UNSIGNED` | **PK**, required | Unique enrollment identifier. |
| `member_id` | `BIGINT UNSIGNED` | **FK** → `members.member_id`, required | Enrolled participant. |
| `class_session_id` | `BIGINT UNSIGNED` | **FK** → `class_sessions.class_session_id`, required | Session booked. |
| `enrollment_status` | `VARCHAR(20)` | Required | Proposed values: `booked`, `canceled`, `attended`, `no_show`. |
| `enrolled_at` | `DATETIME` | Required | When the member registered. |
| `canceled_at` | `DATETIME` | Optional | When this booking was canceled. |

**Notes:** Add **UQ** (`member_id`, `class_session_id`) to prevent duplicate enrollment in the same session. Rebooking a canceled session can update the existing row. Check capacity and membership/trial class access before booking. `attended` versus `no_show` supports attendance analysis.

### E11 — `payments`

**Purpose:** Record transactions against purchased memberships and support revenue reporting.

| Attribute | Proposed MySQL type | Key / required? | Meaning |
|---|---|---|---|
| `payment_id` | `BIGINT UNSIGNED` | **PK**, required | Unique payment identifier. |
| `membership_id` | `BIGINT UNSIGNED` | **FK** → `memberships.membership_id`, required | Subscription being paid for. |
| `amount` | `DECIMAL(10,2)` | Required | Amount of transaction; must be nonnegative. |
| `payment_method` | `VARCHAR(20)` | Required | Proposed values: `card`, `cash`, `bank_transfer`. |
| `payment_status` | `VARCHAR(20)` | Required | Proposed values: `pending`, `completed`, `failed`, `refunded`. |
| `paid_at` | `DATETIME` | Optional | Successful payment time; normally present for completed payments. |
| `created_at` | `DATETIME` | Required | When the payment record was created. |
| `transaction_reference` | `VARCHAR(100)` | Optional, **UQ** when present | External or simulated transaction identifier. |

**Notes:** The historical payment amount must not be reconstructed from the current plan price. Under the simplified business rule, reporting counts completed, non-refunded payments only. Partial refunds and accounting-grade revenue recognition are **out of scope**; in this classroom project the report is more precisely *completed payment receipts* rather than formal accrual-basis recognized revenue.

## 3. Key entity relationships (input for the ER diagram)

| Parent (one) | Child (many) | Relationship | Child FK |
|---|---|---|---|
| `members` | `memberships` | One member can hold many subscriptions over time. | `memberships.member_id` |
| `membership_plans` | `memberships` | One plan can be purchased in many subscriptions. | `memberships.plan_id` |
| `memberships` | `memberships` | One subscription can be renewed as another. | `memberships.renewed_from_membership_id` (optional) |
| `members` | `free_trials` | One member can have zero or more trials (subject to trial policy). | `free_trials.member_id` |
| `members` | `gym_visits` | One member can make many gym visits. | `gym_visits.member_id` |
| `members` | `amenity_reservations` | One member can make many amenity bookings. | `amenity_reservations.member_id` |
| `amenities` | `amenity_reservations` | One amenity can have many bookings. | `amenity_reservations.amenity_id` |
| `class_types` | `class_sessions` | One type can be scheduled repeatedly. | `class_sessions.class_type_id` |
| `members` | `class_enrollments` | One member can enroll in many class sessions. | `class_enrollments.member_id` |
| `class_sessions` | `class_enrollments` | One session can have many members. | `class_enrollments.class_session_id` |
| `memberships` | `payments` | One subscription can have multiple payment attempts or transactions. | `payments.membership_id` |

**Many-to-many relationships resolved by associative entities:**

- `members` ↔ `class_sessions` through `class_enrollments`.
- `members` ↔ `amenities` through `amenity_reservations`.
- `members` ↔ `membership_plans` through `memberships` (with dates and historical attributes).

## 4. Attribute classification and important design decisions

- **Primary keys:** Each of the 11 entities has one surrogate ID (`*_id`).
- **Foreign keys:** Used for all cross-entity relationships listed above; do not copy member names, plan names, or class names into the transactional tables.
- **Calculated attributes, not stored:** Member age, age group, active-member counts, attendance frequency, trial conversion rate, class attendance rate, and plan popularity. Calculate them in SQL queries. A person's age must be calculated relative to the visit/report date, not today's date for all historical analysis.
- **Controlled status values:** Use `VARCHAR` with `CHECK` constraints or `ENUM` at SQL implementation; ensure allowed states and transitions are documented.
- **Money:** Use `DECIMAL`, not `FLOAT`/`DOUBLE`.
- **Times:** Use `DATETIME` consistently for local gym operations, with the project assuming one New York City location. Document timezone handling before a multi-location expansion.
- **Privacy:** Store only information required for gym operations and analytics; no medical details or payment-card numbers.
- **Historical integrity:** Do not delete old visits, bookings, completed payments, or subscriptions merely because a plan, class, or facility is deactivated.
- **Uniqueness:** Unique emails, plan names, amenity names, class type names, and (`member_id`, `class_session_id`) prevent intended duplicates; confirm business assumptions before implementation.
- **Capacity and overlap:** Amenity concurrent capacity and class enrollment limits cannot be guaranteed by ordinary per-row `CHECK` constraints. Enforce them with transactions and a defined booking process, then test them.
- **Service-specific entitlements:** Broad `includes_classes` and `includes_amenities` flags are adequate for the baseline 11-table version. Precise access to particular amenities/classes would need additional mapping tables and is *not fully modeled yet*.

## 5. Requirement coverage

| Business requirement | Key entities / attributes |
|---|---|
| BR-01 Member management | `members` (`member_id`, contact fields, `date_of_birth`) and `memberships.membership_status` |
| BR-02 Membership plans | `membership_plans` (term, price, inclusion flags) |
| BR-03 Membership history | `memberships` (`start_date`, `end_date`, `renewed_from_membership_id`, status) |
| BR-04 Free-trial conversion | `free_trials` joined to later `memberships` by `member_id` |
| BR-05 Gym attendance | `gym_visits` (`check_in_at`, `check_out_at`) |
| BR-06 Amenity catalog | `amenities` |
| BR-07 Amenity booking | `amenity_reservations`, `amenities.capacity` |
| BR-08 Class scheduling | `class_types`, `class_sessions` |
| BR-09 Enrollment outcomes | `class_enrollments` |
| BR-10 Payment tracking | `payments` |
| BR-11 Management reporting | Date/time, fee, status, plan, class, and member-related attributes across entities |
| BR-12 Data integrity | PKs, FKs, unique rules, allowed statuses, time validity, and transactional booking logic |

## 6. Analytical-question coverage

| Analytical question | Primary join path and measures |
|---|---|
| AQ-01 Peak usage by day, hour, plan, and age | `gym_visits` → `members`, plus valid `memberships` → `membership_plans` for the visit date. Count visits and derive hour/day/age group. |
| AQ-02 Popular classes and amenities | `class_enrollments` → `class_sessions` → `class_types`; `amenity_reservations` → `amenities`. Count bookings/attended/completed; approximate reservation-based utilization using bookings and capacity. |
| AQ-03 Trial conversion within 30 days | `free_trials` → `members` → `memberships`; compare paid membership `start_date` with trial `end_date`. |
| AQ-04 Membership plan performance | `membership_plans` → `memberships` → `payments`; count subscriptions/renewals and sum completed, non-refunded receipts. |
| AQ-05 Usage by demographics | `members` → `gym_visits`, `class_enrollments`, `amenity_reservations`, plus `memberships` for membership categories. Calculate age groups at the relevant event date. |

## 7. Assumptions to confirm before Step 3

1. **One gym location.** No `locations` table is needed.
2. **Prices are per plan term.** The duration is measured in months.
3. **Bookings reserve spots.** `guest_count` counts amenity capacity, while each class enrollment counts one class seat.
4. **No overlapping eligible paid memberships per member** unless the team defines a rule for which one controls access and reporting.
5. **Trial participants are stored in `members`**, even before purchasing a subscription.
6. **A converted trial** is one where a paying membership starts within 30 days *after* trial end. Other definitions are possible, but the team must use one consistently.
7. **Broad benefit levels only.** More detailed service-based access requires adding entities beyond the original 11.
8. **Payment revenue report** means completed, non-refunded receipts; financial accounting recognition is outside scope.
9. **Trainer schedules, multiple branches, and automated billing** are outside scope.

## 8. Completion checklist

- [x] Identified all 11 core business entities.
- [x] Defined the candidate attributes and MySQL data types for each entity.
- [x] Marked each primary and foreign key.
- [x] Identified required versus optional attributes.
- [x] Identified uniqueness, validation, and historical-data rules.
- [x] Mapped all entities to requirements and analytical questions.
- [x] Documented assumptions and limitations for the initial scope.

**Next step (Step 3):** Draw the entity-relationship diagram (ERD), specifying crow's-foot cardinalities, optional participation, and the candidate key and relationship constraints. After review, translate the logical design into MySQL `CREATE TABLE` statements.
