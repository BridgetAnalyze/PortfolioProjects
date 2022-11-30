--++++++++++++++ USER VERIFICATION IN EACH TABLES+++++++++++=

SELECT 
 COUNT (DISTINCT id) AS unique_ids
FROM
 daily_activity

SELECT 
 COUNT (DISTINCT id) AS unique_ids
FROM
 hourly_steps

 SELECT 
 COUNT (DISTINCT id) AS unique_ids
FROM
 weight_logs

 SELECT 
 COUNT (DISTINCT id) AS unique_ids
FROM
 sleep_activity

--------Breakdown of the users based on their daily log details----------

--Active User - wore their tracker for 25-31 days
--Moderate User - wore their tracker for 15-24 days
--Light User - wore their tracker for 0 to 14 days


SELECT id,
COUNT(id) AS Total_Logged_Users,
CASE
WHEN COUNT(id) BETWEEN 25 AND 31 THEN 'Active User'
WHEN COUNT(id) BETWEEN 15 and 24 THEN 'Moderate User'
WHEN COUNT(id) BETWEEN 0 and 14 THEN 'Light User'
END Fitbit_Usage_type
FROM daily_activity
GROUP BY id

-------Activity of users that are active for the recommended 150mins per week as SUM -------

Select id,
SUM(very_active_minutes+fairly_active_minutes+lightly_active_minutes) AS Total_Minutes_Per_Week,
CASE
WHEN sum(very_active_minutes+fairly_active_minutes+lightly_active_minutes) >= 150 THEN 'Required Minutes Met'
WHEN sum(very_active_minutes+fairly_active_minutes+lightly_active_minutes) <150 THEN 'Required Minutes not Met'
END Recommended_Minutes
FROM daily_activity
WHERE date BETWEEN '2016-04-09' AND '2016-04-15'
GROUP BY id

-------End of the month week's activity---

Select id,
SUM(very_active_minutes+fairly_active_minutes+lightly_active_minutes) AS Total_Minutes_Per_Week,
CASE
WHEN sum(very_active_minutes+fairly_active_minutes+lightly_active_minutes) >= 150 THEN 'Required Minutes Met'
WHEN sum(very_active_minutes+fairly_active_minutes+lightly_active_minutes) <150 THEN 'Required Minutes not Met'
END Recommended_Minutes
FROM daily_activity
WHERE date BETWEEN '2016-05-01' AND '2016-05-07'
GROUP BY id

------Steps based classification of users per day------

SELECT id,
SUM(hourly_steps) AS SUM_total_steps,
CASE
WHEN SUM(hourly_steps) < 5000 THEN 'LOW ACTIVITY LEVEL'
WHEN SUM(hourly_steps) BETWEEN 5000 AND 9999 THEN 'NORMAL ACTIVITY LEVEL'
WHEN SUM(hourly_steps) >= 10000 THEN 'EXCELLENT ACTIVITY LEVEL'
END ACTIVITY_LEVEL
FROM Hourly_steps
WHERE date = '2016-04-23' AND hourly_steps > 0
GROUP BY id
ORDER by ACTIVITY_LEVEL DESC

------Sleep based classification of users per day------

SELECT id,
(ROUND(minutes_asleep/60,1)) AS sleep_hours,
CASE
WHEN (ROUND(minutes_asleep/60,1)) < 7 THEN 'Weak Sleep Cycle'
WHEN (ROUND(minutes_asleep/60,1)) >= 7 THEN 'Recommended Sleep Cycle'
END Sleep_cycle
FROM sleep_activity
ORDER BY Sleep_cycle Desc

----SLEEP VS BMI----

SELECT * ,
CASE
  WHEN BMI > 24.9 THEN 'Overweight'
  WHEN BMI < 18.5 THEN 'Underweight'
  ELSE 'Healthy' END AS BMI_detail
FROM weight_logs
JOIN sleep_activity ON weight_logs.id = sleep_activity.id
order by sleep_activity.minutes_asleep desc

-----STEPS VS BMI

SELECT *,
CASE
  WHEN BMI > 24.9 THEN 'Overweight'
  WHEN BMI < 18.5 THEN 'Underweight'
  ELSE 'Healthy' END AS BMI_detail
FROM weight_logs 
JOIN Hourly_steps ON weight_logs.id = hourly_steps.id
WHERE hourly_steps > 0
order by BMI_detail, hourly_steps desc


