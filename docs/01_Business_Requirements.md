# Luxury Gym Management Database — Business Requirements

**Project:** CIS 3400 — Luxury Gym Management Database  
**Business Type:** Premium fitness club  
**Database Platform:** MySQL 8  
**Document Type:** Business Requirements

## 1. Business Overview

### Project Name
Luxury Gym Management Database

### Business Type
A premium fitness club offering memberships, fitness classes, luxury amenities, and free trials.

### Business Problem
A luxury gym needs an efficient way to manage member information, membership plans, payments, gym attendance, fitness class enrollment.

Without a centralized database, management may struggle to track facility utilization, understand member behavior, evaluate membership performance, and determine which services generate the most demand.

### Business Objective
Develop a relational database that centralizes gym operations and provides reliable information for management to make data-driven decisions about staffing, membership offerings, class schedules, and amenity availability.

The project focuses on building a relational database for a fictional luxury gym, **not** a website or mobile application.

## 2. Stakeholders

| Stakeholder | Business Need |
|---|---|
| Gym Manager | Monitor attendance, membership performance, and facility utilization. |
| Front Desk Staff | Register members, manage trials, and record visits. |
| Class Coordinator | Schedule classes and monitor enrollment. |
| Finance Staff | Track membership payments and revenue. |
| Gym Members | Receive membership access and reserve eligible services. |

## 3. Functional Business Requirements

| ID | Requirement | Description | Priority |
|---|---|---|---|
| BR-01 | Member Management | The gym must maintain member profiles, contact information, and membership status. | High |
| BR-02 | Membership Plans | The gym must offer different membership plans with defined prices, durations, and benefits. | High |
| BR-03 | Membership Tracking | The system must track membership start dates, expiration dates, renewals, and historical plan changes. | High |
| BR-04 | Free Trial Management | The gym must register free trials and track whether trial users become paying members. | High |
| BR-05 | Gym Attendance | The system must record member visits, including check-in dates and times. | High |
| BR-06 | Amenity Management | The gym must maintain information about premium amenities, such as spa facilities, saunas, or pools. | High |
| BR-07 | Amenity Reservations | Members must be able to reserve eligible amenities subject to availability and capacity. | High |
| BR-08 | Fitness Class Scheduling | The gym must maintain class types, scheduled sessions, dates, times, and capacities. | High |
| BR-09 | Class Enrollment | The system must record bookings, cancellations, attendance, and no-shows. | High |
| BR-10 | Payment Tracking | The gym must record membership payments, amounts, dates, and payment statuses. | High |
| BR-11 | Management Reporting | The database must support queries that help management analyze member behavior and operational performance. | High |
| BR-12 | Data Accuracy | The system must prevent invalid records, duplicate bookings, and inconsistent membership information. | High |

## 4. Business Rules

The database must enforce the following business rules:

1. Each member must have a unique member identifier.
2. A member may have multiple memberships over time, but historical memberships must be preserved.
3. Membership eligibility must be determined using the membership's start date, expiration date, and status.
4. Each free trial must have a defined beginning and ending date.
5. A gym visit must belong to an existing member.
6. Amenity reservations must not exceed available capacity.
7. A member must not have duplicate bookings for the same fitness class session.
8. Class enrollment must respect the session's maximum capacity.
9. Cancellations, attendance, and no-shows must be recorded as distinct outcomes.
10. Only completed, non-refunded payments should count toward recognized payment revenue in management reports.
11. Historical attendance and payment records must be retained for analysis.
12. Booking eligibility must be based on an active membership or a valid trial that grants access to the requested service.

## 5. Analytical Business Requirements

The database must provide sufficient information to answer **five primary business questions**.

### AQ-01: When is the gym busiest?

Identify peak gym usage by day of the week, hour, membership plan, and member age group.

**Business value:** Improve staffing decisions and reduce overcrowding.

### AQ-02: Which amenities and fitness classes are most popular?

Determine the amenities with the highest reservation and utilization rates, and the classes with the highest enrollment and attendance.

**Business value:** Improve class scheduling and resource allocation.

### AQ-03: How effective are free trials at attracting paying members?

Measure the percentage of trial members who purchase a membership within 30 days of their trial ending.

**Business value:** Evaluate marketing effectiveness and customer acquisition.

### AQ-04: Which membership plans are most popular?

Compare plans using new subscriptions, active members, renewals, and completed payments.

**Business value:** Identify successful plans and guide pricing decisions.

### AQ-05: How does gym usage differ among member demographics?

Analyze attendance frequency, class participation, and amenity usage across age groups and membership categories.

**Business value:** Understand customer preferences and support targeted service improvements.

## 6. Project Scope

### Included

- Member records
- Membership plans
- Membership histories
- Free trials
- Gym visits
- Premium amenities
- Amenity reservations
- Fitness classes
- Class sessions
- Enrollments
- Payment records

### Excluded

- Website development
- Mobile applications
- Live payment-processing integrations
- Employee payroll
- Equipment inventory
- Advanced predictive or machine-learning models

The project will use a **single fictional gym location** and realistic sample data.

## 7. Success Criteria

The project will be considered successful when the database:

- Supports all eleven core business entities.
- Preserves relationships between members, memberships, payments, visits, reservations, and classes.
- Enforces essential business rules and data-integrity constraints.
- Provides SQL queries that answer all five analytical questions.
- Uses a normalized relational design, targeting Third Normal Form (3NF).
- Produces reliable management reports using realistic sample records.

**Final deliverable:** A working MySQL 8 relational database, accompanied by an entity-relationship diagram, data dictionary, SQL creation and sample-data scripts, and analytical queries.

## 8. Proposed Database Tables

The business requirements lead to the following **11 proposed tables**:

| # | Table Name | Purpose |
|---|---|---|
| 1 | `members` | Member profiles and contact information. |
| 2 | `membership_plans` | Available plans, prices, durations, and benefits. |
| 3 | `memberships` | Membership subscriptions, status, renewals, and history. |
| 4 | `free_trials` | Trial periods and subsequent conversion tracking. |
| 5 | `gym_visits` | Member check-ins and usage history. |
| 6 | `amenities` | Premium facilities and their capacities. |
| 7 | `amenity_reservations` | Member amenity bookings and their statuses. |
| 8 | `class_types` | Types of fitness classes offered. |
| 9 | `class_sessions` | Individual scheduled class occurrences and capacities. |
| 10 | `class_enrollments` | Class bookings, cancellations, attendance, and no-shows. |
| 11 | `payments` | Payment transactions and payment status. |

## 9. Next Step

Define the entities, attributes, primary keys, foreign keys, and relationships for the entity-relationship (ER) diagram. This will translate the business requirements into a logical database design before writing the MySQL table creation scripts.
