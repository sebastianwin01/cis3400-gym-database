-- How does peak gym usage break down?
SELECT
    DAYNAME(check_in_at) AS day_of_week,
    HOUR(check_in_at) AS hour_of_day,
    COUNT(*) AS total_visits
FROM gym_visits
GROUP BY
    DAYOFWEEK(check_in_at),
    DAYNAME(check_in_at),
    HOUR(check_in_at)
ORDER BY total_visits DESC;