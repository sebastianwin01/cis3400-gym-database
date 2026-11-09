# Luxury Gym Management Database — Business Requirements

**Course:** CIS 3400  
**Database:** MySQL 8  
**Project scope:** Six-table relational database for a gym with multiple locations

## 1. Business Overview

The luxury gym operates several locations and needs a centralized database to organize basic member, membership, payment, and visit information. The same membership can be used at any active gym location.

This project focuses on **database design and data analysis**, not on building a website, mobile app, or complete gym management system.

## 2. Business Objective

Create a relational database that stores accurate gym records and supports simple analysis of:

- Gym attendance by location, day, and time.
- Membership plan popularity.
- Payment revenue by location and borough.
- Member demographics and gym usage.
- Visit frequency and duration.

## 3. Business Requirements

| ID | Requirement | Description |
|---|---|---|
| BR-01 | Manage members | Store basic member details, contact information, birth dates, and joining dates. |
| BR-02 | Manage membership plans | Store available plans, levels, durations, and prices. |
| BR-03 | Track memberships | Link members to their plans and keep their start dates, end dates, and creation dates. |
| BR-04 | Record gym visits | Record when a member enters and exits a specific gym location. |
| BR-05 | Track payments | Record membership payments, amounts, dates, and the locations associated with those payments. |
| BR-06 | Manage locations | Store each gym location's name, borough, operating hours, and active status. |
| BR-07 | Support multiple locations | Allow members with valid memberships to use any active gym location. |
| BR-08 | Support reporting | Allow management to query membership, attendance, demographic, and payment information. |

## 4. Database Scope

The database consists of **six tables**:

| Table | Purpose |
|---|---|
| `members` | Member personal and contact information. |
| `membership_plans` | Available plan options and prices. |
| `memberships` | A member's enrollment in a membership plan. |
| `gym_visits` | Member check-ins and check-outs at gym locations. |
| `payments` | Recorded payments associated with memberships and locations. |
| `locations` | Gym branch details and operating information. |

The tables are connected through primary keys and foreign keys. No additional tables are included in the current project scope.

## 5. General Business Rules

1. Each member, plan, membership, visit, payment, and location has a unique identifier.
2. Each membership belongs to one member and one membership plan. A member may have multiple memberships over time.
3. Each gym visit belongs to one member and one location. The check-out time may be empty until the member leaves.
4. Each payment belongs to one membership and is attributed to one location.
5. Members with a valid membership may visit any active gym location; memberships are not restricted to one branch.
6. Membership records are retained for history. The membership end date may be empty when not yet known.
7. Member emails must be unique.

## 6. Analytical Questions

The project should answer these five business questions using SQL:

1. **Peak attendance:** Which gym locations, days, and hours receive the most visits?
2. **Plan popularity:** Which membership plans are most commonly selected?
3. **Revenue:** How do recorded payment totals compare across locations and boroughs?
4. **Demographics:** How does gym usage vary across member age groups?
5. **Member activity:** How frequently do members visit, and how long do they stay?

## 7. Out of Scope

The project does not cover free trials, class scheduling, amenity reservations, employee management, payment processing integrations, or an application interface.

## 8. Success Criteria

The project is complete when:

- All six tables and their relationships are correctly implemented in MySQL.
- Sample records can be inserted without violating key constraints.
- Member, membership, payment, and visit data can be joined correctly.
- SQL queries answer the five analytical questions.
- The database design, ER diagram, and query findings are documented.

---

**Next project step:** Review the six-table data dictionary and ER diagram against these requirements, then validate normalization before implementing the MySQL schema.
