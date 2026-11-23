-- How many people of each age group attend morning, afternoon, and evening?

-- generate a view table that divides to query 
WITH visit_categories AS (
    SELECT 
     -- 
        gv.member_id,
       
        CASE
            WHEN TIMESTAMPDIFF(
                YEAR, m.date_of_birth, gv.check_in_at
            ) < 25 THEN '18-24'

            WHEN TIMESTAMPDIFF(
                YEAR, m.date_of_birth, gv.check_in_at
            ) < 35 THEN '25-34'

            WHEN TIMESTAMPDIFF(
                YEAR, m.date_of_birth, gv.check_in_at
            ) < 45 THEN '35-44'

            WHEN TIMESTAMPDIFF(
                YEAR, m.date_of_birth, gv.check_in_at
            ) < 55 THEN '45-54'

            WHEN TIMESTAMPDIFF(
                YEAR, m.date_of_birth, gv.check_in_at
            ) < 65 THEN '55-64'
            ELSE '65+'
        END AS age_group,

        CASE
            WHEN HOUR(gv.check_in_at) < 12
                THEN 'Morning'
            WHEN HOUR(gv.check_in_at) < 17
                THEN 'Afternoon'
            ELSE 'Evening'
        END AS time_period

    FROM gym_visits gv
    JOIN members m
        ON gv.member_id = m.member_id
)

SELECT
    age_group,
    time_period,
    COUNT(DISTINCT member_id) AS unique_members
FROM visit_categories
GROUP BY age_group, time_period
ORDER BY age_group, time_period;

