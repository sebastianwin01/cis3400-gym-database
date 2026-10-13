-- CIS 3400 Gym Management Database | Step 2
-- Run after create_database.sql.
-- Core tables follow the eight-entity scope in docs/proposal.md.
USE gym_database;

CREATE TABLE IF NOT EXISTS members (
    member_id INT AUTO_INCREMENT PRIMARY KEY,
    first_name VARCHAR(50) NOT NULL,
    last_name VARCHAR(50) NOT NULL,
    email VARCHAR(255) NOT NULL UNIQUE,
    birth_date DATE,
    join_date DATE NOT NULL
);

CREATE TABLE IF NOT EXISTS membership_plans (
    plan_id INT AUTO_INCREMENT PRIMARY KEY,
    plan_name VARCHAR(50) NOT NULL UNIQUE,
    price DECIMAL(10, 2) NOT NULL,
    duration_days INT NOT NULL,
    description VARCHAR(255),
    CONSTRAINT chk_plan_price CHECK (price >= 0),
    CONSTRAINT chk_plan_duration CHECK (duration_days > 0)
);

CREATE TABLE IF NOT EXISTS memberships (
    membership_id INT AUTO_INCREMENT PRIMARY KEY,
    member_id INT NOT NULL,
    plan_id INT NOT NULL,
    start_date DATE NOT NULL,
    end_date DATE NOT NULL,
    status ENUM('active', 'expired', 'canceled') NOT NULL,
    CONSTRAINT chk_membership_dates CHECK (end_date >= start_date),
    CONSTRAINT uq_member_start UNIQUE (member_id, start_date),
    CONSTRAINT fk_membership_member FOREIGN KEY (member_id)
        REFERENCES members(member_id)
        ON UPDATE CASCADE ON DELETE RESTRICT,
    CONSTRAINT fk_membership_plan FOREIGN KEY (plan_id)
        REFERENCES membership_plans(plan_id)
        ON UPDATE CASCADE ON DELETE RESTRICT
);

CREATE TABLE IF NOT EXISTS payments (
    payment_id INT AUTO_INCREMENT PRIMARY KEY,
    membership_id INT NOT NULL,
    amount DECIMAL(10, 2) NOT NULL,
    payment_date DATE NOT NULL,
    payment_status ENUM('completed', 'pending', 'failed', 'refunded') NOT NULL,
    payment_method ENUM('card', 'cash', 'bank_transfer') NOT NULL,
    CONSTRAINT chk_payment_amount CHECK (amount > 0),
    CONSTRAINT fk_payment_membership FOREIGN KEY (membership_id)
        REFERENCES memberships(membership_id)
        ON UPDATE CASCADE ON DELETE RESTRICT
);

CREATE TABLE IF NOT EXISTS trainers (
    trainer_id INT AUTO_INCREMENT PRIMARY KEY,
    first_name VARCHAR(50) NOT NULL,
    last_name VARCHAR(50) NOT NULL,
    email VARCHAR(255) NOT NULL UNIQUE,
    specialization VARCHAR(100),
    hire_date DATE NOT NULL
);

CREATE TABLE IF NOT EXISTS class_types (
    class_type_id INT AUTO_INCREMENT PRIMARY KEY,
    type_name VARCHAR(80) NOT NULL UNIQUE,
    description VARCHAR(255)
);

CREATE TABLE IF NOT EXISTS class_sessions (
    session_id INT AUTO_INCREMENT PRIMARY KEY,
    class_type_id INT NOT NULL,
    trainer_id INT NOT NULL,
    starts_at DATETIME NOT NULL,
    ends_at DATETIME NOT NULL,
    capacity INT NOT NULL,
    CONSTRAINT chk_session_capacity CHECK (capacity > 0),
    CONSTRAINT chk_session_times CHECK (ends_at > starts_at),
    CONSTRAINT uq_trainer_start UNIQUE (trainer_id, starts_at),
    CONSTRAINT fk_session_type FOREIGN KEY (class_type_id)
        REFERENCES class_types(class_type_id)
        ON UPDATE CASCADE ON DELETE RESTRICT,
    CONSTRAINT fk_session_trainer FOREIGN KEY (trainer_id)
        REFERENCES trainers(trainer_id)
        ON UPDATE CASCADE ON DELETE RESTRICT
);

CREATE TABLE IF NOT EXISTS enrollments (
    enrollment_id INT AUTO_INCREMENT PRIMARY KEY,
    member_id INT NOT NULL,
    session_id INT NOT NULL,
    booked_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    status ENUM('booked', 'canceled', 'attended', 'missed') NOT NULL DEFAULT 'booked',
    CONSTRAINT uq_member_session UNIQUE (member_id, session_id),
    CONSTRAINT fk_enrollment_member FOREIGN KEY (member_id)
        REFERENCES members(member_id)
        ON UPDATE CASCADE ON DELETE RESTRICT,
    CONSTRAINT fk_enrollment_session FOREIGN KEY (session_id)
        REFERENCES class_sessions(session_id)
        ON UPDATE CASCADE ON DELETE RESTRICT
);

-- See the structure and relationships in MySQL.
SHOW TABLES;
SHOW CREATE TABLE enrollments;
