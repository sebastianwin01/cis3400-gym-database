# Step 2 — Identify Entities and Attributes (Multi-Location Version)

**Project:** CIS 3400 — Luxury Gym Management Database  
**Database:** MySQL 8  
**Design stage:** Conceptual-to-logical data model (before ER diagram and `CREATE TABLE` statements)  
**Reference:** `luxury_gym_business_requirements.md` (its original single-location scope is superseded by this multi-location decision)  
**Scope:** **12 entities**, with network-wide access for eligible paid memberships and valid trials; no location-specific membership tiers.  
**Version:** 2.0 — November 8, 2026

## 1. Objective and access model

Identify the business entities, attributes, keys, and relationships needed to support multiple gym branches within one shared MySQL database. This is a **proposed data dictionary**, not final SQL DDL; the ER diagram and normalization review will confirm final SQL constraints and column types.

**Access model:** One member profile and one paid membership work across **every active location**. A member can check in at any active branch during a valid membership term. A valid free trial also permits network-wide visits for this classroom version; the trial's registration branch is recorded for attribution. The `includes_classes` and `includes_amenities` flags still determine service eligibility. Members' preferred branch and subscriptions' sales branch are **descriptive**, not access controls.

**Notation:** **PK** = primary key; **FK** = foreign key; **UQ** = unique; **Required** = a value must be provided; **Optional** = `NULL` permitted. IDs use proposed `BIGINT UNSIGNED` auto-generated keys.

### 1.1 Changes from the original 11-entity design

| Entity | Change | Why |
|---|---|---|
| `locations` | **New** 12th entity | Store one record per branch. |
| `members` | Add optional `home_location_id` | Track preferred branch without limiting access. |
| `memberships` | Add optional `sold_at_location_id` | Attribute sales to originating branch. |
| `free_trials` | Add required `registered_at_location_id` | Track trial acquisition by branch. |
| `gym_visits` | Add required `location_id` | Record the actual branch visited. |
| `amenities` | Add required `location_id`; replace global amenity-name uniqueness with per-branch uniqueness | Facilities belong to physical locations. |
| `class_sessions` | Add required `location_id` | Scheduled classes happen at a specific branch. |
| `payments` | Add optional `collected_at_location_id` | Analyze transactions collected at branches; `NULL` = online/unassigned. |
| `membership_plans`, `class_types` | No location key | Global catalogs shared by all branches. |
| `amenity_reservations`, `class_enrollments` | No location key | Location is already determined by the referenced amenity or session. |

## 2. Entity and attribute dictionary

### E01 — `locations`

**Purpose:** Identify each gym branch and store branch-level details. This is the central parent entity for location-based operations; it does **not** restrict where a paid member may enter.

| Attribute | Proposed MySQL type | Key / required? | Meaning |
|---|---|---|---|
| `location_id` | `BIGINT UNSIGNED` | **PK**, required | Unique branch identifier. |
| `location_name` | `VARCHAR(100)` | **UQ**, required | Branch label, e.g., Luxury Gym Queens. |
| `street_address` | `VARCHAR(255)` | Required | Physical street address of the branch. |
| `city` | `VARCHAR(100)` | Required | City. |
| `state` | `VARCHAR(50)` | Required | State / administrative region. |
| `postal_code` | `VARCHAR(15)` | Required | Postal or ZIP code. |
| `phone` | `VARCHAR(25)` | Optional | Branch contact phone number. |
| `time_zone` | `VARCHAR(64)` | Required | IANA time-zone name, e.g., `America/New_York`. |
| `opening_time` | `TIME` | Optional | Standard local opening time (simplified schedule). |
| `closing_time` | `TIME` | Optional | Standard local closing time (simplified schedule). |
| `is_active` | `BOOLEAN` (`TINYINT(1)`) | Required | Whether this branch currently operates and accepts new visits/bookings. |

**Notes:** `location_name` is assumed unique within the gym chain. Standard opening/closing times do not fully model different weekday or holiday hours; that would require a separate `location_hours` table (out of scope). Inactive locations remain in the database to preserve historical transactions. Current scope assumes real physical branches, not virtual services.

### E02 — `members`

**Purpose:** Store one profile for each gym member or free-trial participant. A person's subscription status is kept in `memberships`, rather than duplicated here.

| Attribute | Proposed MySQL type | Key / required? | Meaning |
|---|---|---|---|
| `member_id` | `BIGINT UNSIGNED` | **PK**, required | Unique member identifier. |
| `first_name` | `VARCHAR(60)` | Required | Member's given name. |
| `last_name` | `VARCHAR(60)` | Required | Member's surname. |
| `email` | `VARCHAR(255)` | **UQ**, required | Contact email; unique per profile. |
| `phone` | `VARCHAR(25)` | Optional | Phone number. |
| `date_of_birth` | `DATE` | Required | Enables age-group analyses; age itself is calculated rather than stored. |
| `home_location_id` | `BIGINT UNSIGNED` | Optional **FK** → `locations.location_id` | Member's preferred/home branch; for reporting only, **not** an access restriction. |
| `joined_at` | `DATETIME` | Required | Date and time profile was created. |

**Notes:** Member records should be retained for links to historical bookings, payments, and visits. If the real gym permits shared contact emails, revisit the email uniqueness rule.

**Multi-location note:** `home_location_id` is a preference used to analyze home-versus-visited branches. A member may visit **any active branch** while holding an eligible membership. Home-branch changes do not alter the location of past visits.

### E03 — `membership_plans`

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

**Multi-location note:** Membership plans are shared across the entire chain: no `location_id` or plan-to-location junction is needed. Every valid paid plan allows access to every active branch. `includes_classes` and `includes_amenities` control service privileges, not which branch a person may visit.

### E04 — `memberships`

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
| `sold_at_location_id` | `BIGINT UNSIGNED` | Optional **FK** → `locations.location_id` | Branch credited for the membership sale; `NULL` for online or unassigned sales. |
| `created_at` | `DATETIME` | Required | When this subscription record was created. |

**Notes:** `end_date >= start_date`. Decide during Step 3 whether cancellation ends access immediately or at the paid-through date. A member can have multiple historical memberships, but any overlapping *eligible* memberships must be handled by an explicit policy to avoid ambiguous plan attribution.

**Multi-location note:** `sold_at_location_id` captures the **sales attribution branch** and never restricts member access. An eligible paid membership grants visits across all active locations; `NULL` means purchased online/unassigned. Sales by branch can group by this field, while attendance uses `gym_visits.location_id`.

### E05 — `free_trials`

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
| `registered_at_location_id` | `BIGINT UNSIGNED` | **FK** → `locations.location_id`, required | Branch that registered the trial; used for conversion attribution. |
| `created_at` | `DATETIME` | Required | When the trial was registered. |

**Notes:** `end_date >= start_date`. Do **not** store a separate `converted_to_member` boolean: conversion is determined from later records in `memberships`, using the same `member_id`. A conversion within 30 days of trial end means a paid subscription starts after the trial ends and no later than 30 days afterward (final business definition subject to confirmation).

**Multi-location note:** For this version, a valid trial may also be used at **any active branch** (subject to its class/amenity privileges). `registered_at_location_id` identifies the origin branch for marketing analysis, not a restriction.

### E06 — `gym_visits`

**Purpose:** Record attendance at the gym and support peak-use and demographic analyses.

| Attribute | Proposed MySQL type | Key / required? | Meaning |
|---|---|---|---|
| `visit_id` | `BIGINT UNSIGNED` | **PK**, required | Unique visit identifier. |
| `member_id` | `BIGINT UNSIGNED` | **FK** → `members.member_id`, required | Person who checked in. |
| `location_id` | `BIGINT UNSIGNED` | **FK** → `locations.location_id`, required | Branch where the check-in occurred. |
| `check_in_at` | `DATETIME` | Required | Time member entered the gym. |
| `check_out_at` | `DATETIME` | Optional | Time member exited; `NULL` when not recorded yet. |

**Notes:** `check_out_at IS NULL OR check_out_at >= check_in_at`. Access must be validated against a valid membership or trial *at check-in time*. For AQ-01, attribute a visit to the eligible membership covering the visit timestamp; the overlapping-membership policy must prevent ambiguity.

**Multi-location note:** The same `member_id` may appear in visits at several branches. The location is stored **on the actual visit**, never inferred from `members.home_location_id` or a membership sale. A member can have at most one open visit across the chain at a time (enforced by check-in workflow).

### E07 — `amenities`

**Purpose:** Catalog premium facilities members can use or reserve.

| Attribute | Proposed MySQL type | Key / required? | Meaning |
|---|---|---|---|
| `amenity_id` | `BIGINT UNSIGNED` | **PK**, required | Unique amenity identifier. |
| `location_id` | `BIGINT UNSIGNED` | **FK** → `locations.location_id`, required | Branch containing the bookable facility. |
| `amenity_name` | `VARCHAR(100)` | Required; **UQ** with `location_id` | Name of this specific bookable facility within a branch. |
| `description` | `TEXT` | Optional | Facility details or usage rules. |
| `capacity` | `SMALLINT UNSIGNED` | Required | Maximum simultaneous reserved guests; must be positive. |
| `requires_reservation` | `BOOLEAN` (`TINYINT(1)`) | Required | Whether advance booking is required. |
| `is_active` | `BOOLEAN` (`TINYINT(1)`) | Required | Whether amenity is offered and bookable. |

**Notes:** For the 11-table version, each amenity row represents one bookable facility. If there are multiple identical rooms or equipment units that need separate availability, model each as a distinct amenity row or introduce a resource table later.

**Multi-location note:** The same amenity name may exist at different branches. Replace global `UQ(amenity_name)` with **`UQ(location_id, amenity_name)`**; use distinct names such as `Sauna A`/`Sauna B` when a branch has multiple facilities of the same kind.

### E08 — `amenity_reservations`

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

**Multi-location note:** Do **not** duplicate `location_id` here: resolve it through `amenity_reservations.amenity_id` → `amenities.location_id`. Reservations are only allowed while the facility's location is active. Capacity checks apply **per amenity at that location**.

### E09 — `class_types`

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

**Multi-location note:** Class types are a **chain-wide catalog**. Multiple locations can schedule the same class type without duplicating its description.

### E10 — `class_sessions`

**Purpose:** Store each dated and timed occurrence of a fitness class.

| Attribute | Proposed MySQL type | Key / required? | Meaning |
|---|---|---|---|
| `class_session_id` | `BIGINT UNSIGNED` | **PK**, required | Unique scheduled session identifier. |
| `class_type_id` | `BIGINT UNSIGNED` | **FK** → `class_types.class_type_id`, required | Type of class being held. |
| `location_id` | `BIGINT UNSIGNED` | **FK** → `locations.location_id`, required | Branch where the class is held. |
| `starts_at` | `DATETIME` | Required | Scheduled start time. |
| `ends_at` | `DATETIME` | Required | Scheduled end time. |
| `max_capacity` | `SMALLINT UNSIGNED` | Required | Maximum number of enrolled attendees; must be positive. |
| `room_name` | `VARCHAR(80)` | Optional | Where the class takes place. |
| `session_status` | `VARCHAR(20)` | Required | Proposed values: `scheduled`, `completed`, `canceled`. |

**Notes:** Require `ends_at > starts_at`. Capacity is applied to active booked enrollments, not canceled records. Trainer/staff management is excluded from the current 11-entity scope; add a `trainers` table in a future iteration if instructor assignments become a business requirement.

**Multi-location note:** Every scheduled session belongs to **one branch**, even if its class type is offered chain-wide. Session times and `room_name` refer to that branch. Prevent overlapping sessions in the same `(location_id, room_name)` with scheduling logic, where `room_name` is present.

### E11 — `class_enrollments`

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

**Multi-location note:** Resolve branch through `class_enrollments.class_session_id` → `class_sessions.location_id`; no extra location key is needed. An eligible member can enroll in classes at any active branch if the plan/trial includes class access.

### E12 — `payments`

**Purpose:** Record transactions against purchased memberships and support revenue reporting.

| Attribute | Proposed MySQL type | Key / required? | Meaning |
|---|---|---|---|
| `payment_id` | `BIGINT UNSIGNED` | **PK**, required | Unique payment identifier. |
| `membership_id` | `BIGINT UNSIGNED` | **FK** → `memberships.membership_id`, required | Subscription being paid for. |
| `collected_at_location_id` | `BIGINT UNSIGNED` | Optional **FK** → `locations.location_id` | Branch collecting the payment; `NULL` for online/unassigned transactions. |
| `amount` | `DECIMAL(10,2)` | Required | Amount of transaction; must be nonnegative. |
| `payment_method` | `VARCHAR(20)` | Required | Proposed values: `card`, `cash`, `bank_transfer`. |
| `payment_status` | `VARCHAR(20)` | Required | Proposed values: `pending`, `completed`, `failed`, `refunded`. |
| `paid_at` | `DATETIME` | Optional | Successful payment time; normally present for completed payments. |
| `created_at` | `DATETIME` | Required | When the payment record was created. |
| `transaction_reference` | `VARCHAR(100)` | Optional, **UQ** when present | External or simulated transaction identifier. |

**Notes:** The historical payment amount must not be reconstructed from the current plan price. Under the simplified business rule, reporting counts completed, non-refunded payments only. Partial refunds and accounting-grade revenue recognition are **out of scope**; in this classroom project the report is more precisely *completed payment receipts* rather than formal accrual-basis recognized revenue.

**Multi-location note:** `collected_at_location_id` is the payment collection channel/branch, independent of `memberships.sold_at_location_id`. A receipt can therefore be collected at a different branch than the one that sold the subscription. Keep `NULL` for online payments. Do not infer revenue attribution from visits.

## 3. Entity relationships for Step 3 (ER diagram)

All 12 entities are part of one relational model. **`locations` is the parent for branch-specific records**, while plans and class types remain global.

| Parent (one) | Child (many) | Cardinality and meaning | Child FK |
|---|---|---|---|
| `locations` | `members` | One branch can be home to many members; a member may have no designated home branch. | `members.home_location_id` (optional) |
| `locations` | `memberships` | One branch can sell many subscriptions; an online purchase may lack a sales branch. | `memberships.sold_at_location_id` (optional) |
| `locations` | `free_trials` | One branch registers many trials; each trial has one registration branch. | `free_trials.registered_at_location_id` |
| `locations` | `gym_visits` | One branch receives many visits; each visit happens at exactly one branch. | `gym_visits.location_id` |
| `locations` | `amenities` | One branch contains many specific facilities; each amenity belongs to one branch. | `amenities.location_id` |
| `locations` | `class_sessions` | One branch hosts many sessions; each scheduled session is held at one branch. | `class_sessions.location_id` |
| `locations` | `payments` | One branch may collect many payments; online payments may have no collecting branch. | `payments.collected_at_location_id` (optional) |
| `members` | `memberships` | One member has zero or many subscriptions over time. | `memberships.member_id` |
| `membership_plans` | `memberships` | One shared plan has zero or many purchased subscriptions. | `memberships.plan_id` |
| `memberships` | `memberships` | A subscription may renew an earlier subscription. | `memberships.renewed_from_membership_id` (optional self-FK) |
| `members` | `free_trials` | A member has zero or many trials, according to trial policy. | `free_trials.member_id` |
| `members` | `gym_visits` | A member makes zero or many visits across locations. | `gym_visits.member_id` |
| `members` | `amenity_reservations` | A member may reserve many facilities across locations. | `amenity_reservations.member_id` |
| `amenities` | `amenity_reservations` | One branch-specific facility may receive many reservations. | `amenity_reservations.amenity_id` |
| `class_types` | `class_sessions` | One global class type may be offered in sessions at many branches. | `class_sessions.class_type_id` |
| `members` | `class_enrollments` | A member may book many sessions at any branch. | `class_enrollments.member_id` |
| `class_sessions` | `class_enrollments` | A session may have many member bookings. | `class_enrollments.class_session_id` |
| `memberships` | `payments` | One subscription may have multiple payment transactions/attempts. | `payments.membership_id` |

**Many-to-many relationships represented by existing associative entities:**

- `members` ↔ `class_sessions` via `class_enrollments`.
- `members` ↔ `amenities` via `amenity_reservations`.
- `members` ↔ `membership_plans` via `memberships` (preserving history, dates and statuses).
- `members` ↔ `locations` in **actual visits** via `gym_visits` (multiple members per branch; multiple branches per member). The `home_location_id` is a separate, optional preference.

**No extra `plan_locations` or `membership_location_access` junction table** is needed under the selected model: every eligible paid membership is valid at every active branch. If the team later introduces restricted plans, that would be a **different access model** requiring additional entitlements.

## 4. Rules and constraints specific to multiple locations

1. **Global membership access:** A member with a valid, non-canceled membership whose term includes the **local event date at the visited branch** can check in at any active location. A valid trial also allows visits network-wide for this version. A member's home or sales branch must never be used to deny access.
2. **Service privileges:** Booking a class or amenity requires an eligible membership/trial with the appropriate inclusion flag (`includes_classes` or `includes_amenities`) and the service must be offered at an active branch.
3. **One actual branch per event:** Each visit and class session stores its location explicitly. Each amenity stores its physical location. Reservations and enrollments derive location through the referenced amenity/session, respectively, so no redundant foreign key is added.
4. **Branch uniqueness:** Enforce `UNIQUE(location_id, amenity_name)` instead of global `UNIQUE(amenity_name)`. For example, every branch may have a `Sauna`, but two distinct saunas at one branch must have separate names.
5. **Capacity is local:** Amenity bookings must respect the capacity of the **specific amenity row**. Class enrollments must respect the capacity of the **specific session row**, not a chain-wide aggregate.
6. **Prevent conflicting bookings:** Distinct class sessions cannot overlap in the same named room at the same branch; a member must not have two active reservations/enrollments that conflict in time if the team chooses to enforce cross-location travel feasibility. These are multi-row, cross-table business checks implemented with transactional logic, not ordinary column `CHECK` constraints.
7. **Sales vs. payment collection:** `memberships.sold_at_location_id` represents where a subscription originated, while `payments.collected_at_location_id` represents where a payment was collected. They may differ; `NULL` means online/unassigned. Reports must label which attribution method is used.
8. **Trial attribution:** For conversion reports, attribute a trial to its `registered_at_location_id`, even if the member later buys a subscription at a different branch or online.
9. **Time zones:** Store operational `DATETIME` timestamps in **UTC**. Use `locations.time_zone` to convert to a branch's local calendar date, hour, and weekday in reports; `opening_time` and `closing_time` are local wall-clock times. A membership's date-only eligibility (`start_date` through `end_date`, inclusive) is checked using the branch-local date of the event. For historical visits, do not substitute the member's current home-branch time zone.
10. **Historical data:** Deactivating a branch, facility, or plan does not delete its past visits, sessions, transactions, or relationships. Inactive branches must be blocked for *new* activity but remain queryable for historical analytics.
11. **Access validation is not a simple FK:** Foreign keys confirm records exist, but checking eligibility at a particular location/time requires application logic or stored procedures/transactions. Restricting multiple simultaneous open visits across branches likewise requires transactional workflow validation.
12. **Member identity is chain-wide:** A member has a **single `member_id`** across all branches. `email` remains unique across the gym system (subject to the same caveat about shared addresses as before).
13. **Overlapping subscriptions:** For a clear reporting and authorization rule, the baseline assumes no overlapping eligible paid memberships for a member. Date overlap checks require application logic / transactions.
14. **Branch hours:** `opening_time` and `closing_time` give only standard hours; daily variations or closures require a separate `location_hours` table if added later.

## 5. Attribute classification and database design decisions

- **Primary keys:** All 12 entities have an independently generated surrogate `*_id` PK.
- **Foreign keys:** Seven new FKs to `locations` plus the original relationships; optional origin/collection/home FKs are nullable.
- **Controlled status values:** Use `VARCHAR` + `CHECK` or `ENUM` in MySQL 8; consider allowed transitions when implementing update logic.
- **Money:** `DECIMAL(10,2)` is used for fees and payment amounts; historical payment values are immutable for reporting purposes except explicit corrections.
- **Timestamps:** Event `DATETIME` columns use UTC; derive local-day/hour analyses using the branch time zone. Trial and subscription `DATE` fields are calendar-date entitlements, not UTC timestamps.
- **Derived values (not stored):** Age/age band at visit time, paid active count per branch, cross-branch visit percentage, trial conversion rate, reservation utilization, class attendance rate, and revenue totals.
- **Privacy:** Avoid medical and payment-card details; do not store unnecessary personal information.
- **Preservation:** Prefer deactivation over deletion for records referenced by historical activity; `ON DELETE CASCADE` should not erase transactional history.
- **Unique constraints:** Keep unique email and plan/class type labels, plus `UNIQUE(member_id, class_session_id)` and the new `UNIQUE(location_id, amenity_name)`.
- **Concurrency:** Overlapping reservation guest capacity and class enrollment seats cannot be protected by simple `CHECK` constraints: use locking/transactions to prevent overbooking.
- **Granular rights:** The baseline includes broad classes/amenities access across all active branches; plans that limit specific classes, facilities, or locations are excluded and would need extra mapping tables.

## 6. Requirements coverage (including multi-location BR-13–BR-17)

| Requirement | Key entities / attributes |
|---|---|
| BR-01 Member management | `members`, `memberships` |
| BR-02 Membership plans | `membership_plans` (global catalog) |
| BR-03 Membership history | `memberships` (dates, plan, renewal, status) |
| BR-04 Free trial tracking | `free_trials`, `memberships`, `members` |
| BR-05 Attendance | `gym_visits` with `location_id` and times |
| BR-06 Amenity catalog | `amenities` with `location_id`, capacity |
| BR-07 Amenity reservations | `amenity_reservations`, `amenities` |
| BR-08 Fitness class scheduling | `class_types`, `class_sessions` with `location_id` |
| BR-09 Class enrollment | `class_enrollments`, `class_sessions` |
| BR-10 Payment tracking | `payments`, `memberships` |
| BR-11 Management reporting | Branch-specific events, receipts, statuses, membership data |
| BR-12 Data integrity | PK, FK, UQ, check rules, validation transactions |
| BR-13 Multi-location management | `locations` and all seven new branch FKs |
| BR-14 Branch attendance | `gym_visits.location_id` |
| BR-15 Branch amenity management | `amenities.location_id`, `amenity_reservations` |
| BR-16 Branch performance | `gym_visits.location_id`, `memberships.sold_at_location_id`, `payments.collected_at_location_id`, and `free_trials.registered_at_location_id` |
| BR-17 Cross-location access | Global membership entitlement + member/visit/branch joins; no access junction needed |

*Note:* BR-13 through BR-17 are the proposed additions from the multi-location discussion; the original Step 1 business-requirements file should be amended to incorporate them and replace its single-branch scope.

## 7. Analytical-question coverage

| Analytical question | Primary joins and measures |
|---|---|
| AQ-01 Peak visits by branch, day, hour, plan and age | `gym_visits` → `locations` and `members`; match valid `memberships` → `membership_plans` for each visit date; use branch-local time and age at visit. |
| AQ-02 Popular classes and amenities by branch | `class_enrollments` → `class_sessions` → `locations` and `class_types`; `amenity_reservations` → `amenities` → `locations`. Count attendance/usage per specific branch. |
| AQ-03 Trial conversion by registering branch | `free_trials` → `locations` and `members` → subsequent `memberships`; attribute conversion to the registration location. |
| AQ-04 Membership plan popularity and branch sales/receipts | `membership_plans` → `memberships` → `payments`, using either subscription sales origin (`sold_at_location_id`) or payment collection location (`collected_at_location_id`). Do **not** mix the two definitions. |
| AQ-05 Demographic usage across branches | `members` → `gym_visits` / `class_enrollments` / `amenity_reservations`, then corresponding location path and valid membership plan. |
| **New: AQ-06 Cross-location usage** | `members.home_location_id` versus `gym_visits.location_id`; count visits outside the preferred branch, and distinct locations per member. |
| **New: AQ-07 Branch comparison** | `locations` joined with visits, class sessions, trials and receipts; compare activity/attendance/conversion and payment collection with explicit metric definitions. |

## 8. Assumptions to carry into Step 3

1. **All active branches** accept valid paid memberships; there are no branch-limited plans or plan/location permission tables.
2. Valid free trials also allow visits at active branches; their registration branch is used only for attribution.
3. `home_location_id` may be null and has **no effect on authorization**.
4. `sold_at_location_id` and `collected_at_location_id` may be null for online/unassigned purchases/transactions.
5. Each physical amenity is assigned to one location; each scheduled class session takes place at one location.
6. No overlapping active paid subscriptions for the same member in the baseline implementation; canceled trial and expired memberships do not grant access.
7. Global class types and global plan definitions are shared by all branches, while actual offerings/availability are local.
8. Revenue reports represent **completed non-refunded payment receipts**, not accrual-basis accounting revenue. Branch report attribution must be explicit.
9. Member and location histories remain available after deactivation.
10. Operational event timestamps are UTC, and `locations.time_zone` drives local reporting.
11. Prices are per subscription term; date-only subscription entitlement is inclusive of start and end dates.
12. Trainer/staff schedules, per-day holiday opening schedules, and online payments processing remain out of scope.

## 9. Completion checklist

- [x] Expanded from 11 to **12 entities** with `locations`.
- [x] Defined all proposed attributes and MySQL data types.
- [x] Marked primary keys, foreign keys, unique constraints and optionality.
- [x] Connected branch-specific visits, trials, facilities, sessions, sales and payments to `locations`.
- [x] Kept chain-wide plan access independent of home/sales branches.
- [x] Documented historical integrity, cross-location authorization, and time zones.
- [x] Mapped multi-branch business requirements and analytical questions.

**Next step (Step 3):** Draw a crow's-foot ER diagram with 12 entities, especially the seven FKs to `locations`, and review the access and cardinality assumptions before MySQL implementation.
