USE luxury_gym;
-- Question 5: How does monthly revenue compare by location and borough?

-- Q5(a): Monthly revenue credited to each location.
SELECT DATE_FORMAT(p.paid_at, '%Y-%m') AS payment_month,
       l.location_name,
       SUM(p.amount) AS revenue
FROM payments p
JOIN locations l ON l.location_id = p.location_id
GROUP BY DATE_FORMAT(p.paid_at, '%Y-%m'), l.location_id, l.location_name
ORDER BY payment_month, l.location_name;

-- Q5(b): Monthly revenue credited to each borough.
SELECT DATE_FORMAT(p.paid_at, '%Y-%m') AS payment_month,
       l.borough_name,
       SUM(p.amount) AS revenue
FROM payments p
JOIN locations l ON l.location_id = p.location_id
GROUP BY DATE_FORMAT(p.paid_at, '%Y-%m'), l.borough_name
ORDER BY payment_month, l.borough_name;
