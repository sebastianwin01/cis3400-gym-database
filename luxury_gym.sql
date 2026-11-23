CREATE DATABASE luxury_gym;
use luxury_gym;
--
CREATE TABLE  membership_plans (
    plan_id int AUTO_INCREMENT PRIMARY KEY,
    plan_name varchar(100),
    plan_level varchar(50),
    duration int,
    price decimal(10,2)
);

CREATE TABLE memberships(
    membership_id int AUTO_INCREMENT PRIMARY KEY,
    first_name VARCHAR(50),
    last_name VARCHAR(50),
    email VARCHAR(255) UNIQUE
);

CREATE TABLE members (
    member_id INT AUTO_INCREMENT PRIMARY KEY,
    first_name VARCHAR(60),
    last_name VARCHAR(60),
    email VARCHAR(255) UNIQUE,
    phone VARCHAR(25),
    date_of_birth DATE,
    joining_date DATE
);

CREATE TABLE locations (
    location_id INT AUTO_INCREMENT PRIMARY KEY,
    location_name VARCHAR(100),
    borough_name VARCHAR(50),
    opening_time TIME,
    closing_time TIME,
    is_active BOOLEAN
);

CREATE TABLE gym_visits (
    visit_id INT AUTO_INCREMENT PRIMARY KEY,
    member_id INT,
    location_id INT,
    check_in_at DATETIME,
    check_out_at DATETIME,

    FOREIGN KEY (member_id)
        REFERENCES members(member_id),

    FOREIGN KEY (location_id)
        REFERENCES locations(location_id)
);

CREATE TABLE payments (
    payment_id INT AUTO_INCREMENT PRIMARY KEY,
    membership_id INT,
    location_id INT,
    amount DECIMAL(10,2),
    paid_at DATE,

    FOREIGN KEY (membership_id)
        REFERENCES memberships(membership_id),

    FOREIGN KEY (location_id)
        REFERENCES locations(location_id)
);
