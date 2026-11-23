-- CIS 3400: small, manually maintained gym database (MySQL 8+).
-- Create the Luxury Gym coursework database with a small manually maintained dataset.
CREATE DATABASE IF NOT EXISTS luxury_gym;
USE luxury_gym;

-- Parent tables first.
CREATE TABLE IF NOT EXISTS members (
    member_id INT AUTO_INCREMENT PRIMARY KEY,
    first_name VARCHAR(60) NOT NULL,
    last_name VARCHAR(60) NOT NULL,
    email VARCHAR(255) NOT NULL UNIQUE,
    phone VARCHAR(25),
    date_of_birth DATE,
    joining_date DATE NOT NULL
);

CREATE TABLE IF NOT EXISTS membership_plans (
    plan_id INT AUTO_INCREMENT PRIMARY KEY,
    plan_name VARCHAR(100) NOT NULL UNIQUE,
    plan_level VARCHAR(50) NOT NULL,
    duration INT NOT NULL,
    price DECIMAL(10,2) NOT NULL,
    CONSTRAINT chk_plan_duration CHECK (duration > 0),
    CONSTRAINT chk_plan_price CHECK (price > 0)
);

CREATE TABLE IF NOT EXISTS locations (
    location_id INT AUTO_INCREMENT PRIMARY KEY,
    location_name VARCHAR(100) NOT NULL,
    borough_name VARCHAR(50) NOT NULL,
    opening_time TIME NOT NULL,
    closing_time TIME NOT NULL,
    is_active BOOLEAN NOT NULL DEFAULT TRUE
);

-- Child tables follow, preserving the existing six-table model.
CREATE TABLE IF NOT EXISTS memberships (
    membership_id INT AUTO_INCREMENT PRIMARY KEY,
    member_id INT NOT NULL,
    plan_id INT NOT NULL,
    start_date DATE NOT NULL,
    end_date DATE,
    created_at DATETIME NOT NULL,
    CONSTRAINT fk_memberships_member FOREIGN KEY (member_id) REFERENCES members(member_id),
    CONSTRAINT fk_memberships_plan FOREIGN KEY (plan_id) REFERENCES membership_plans(plan_id),
    CONSTRAINT chk_membership_dates CHECK (end_date IS NULL OR end_date >= start_date)
);

CREATE TABLE IF NOT EXISTS gym_visits (
    visit_id INT AUTO_INCREMENT PRIMARY KEY,
    member_id INT NOT NULL,
    location_id INT NOT NULL,
    check_in_at DATETIME NOT NULL,
    check_out_at DATETIME,
    CONSTRAINT fk_visits_member FOREIGN KEY (member_id) REFERENCES members(member_id),
    CONSTRAINT fk_visits_location FOREIGN KEY (location_id) REFERENCES locations(location_id),
    CONSTRAINT chk_visit_times CHECK (check_out_at IS NULL OR check_out_at >= check_in_at)
);

CREATE TABLE IF NOT EXISTS payments (
    payment_id INT AUTO_INCREMENT PRIMARY KEY,
    membership_id INT NOT NULL,
    location_id INT NOT NULL,
    amount DECIMAL(10,2) NOT NULL,
    paid_at DATE NOT NULL,
    CONSTRAINT fk_payments_membership FOREIGN KEY (membership_id) REFERENCES memberships(membership_id),
    CONSTRAINT fk_payments_location FOREIGN KEY (location_id) REFERENCES locations(location_id),
    CONSTRAINT chk_payment_amount CHECK (amount > 0)
);
