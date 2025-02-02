-- Exploratory Analysis on the auditor report for indepth analysis

DROP TABLE IF EXISTS `auditor_report`;
CREATE TABLE `auditor_report` (
`location_id` VARCHAR(32),
`type_of_water_source` VARCHAR(64),
`true_water_source_score` int DEFAULT NULL,
`statements` VARCHAR(255)
);
Select *
FROM auditor_report;
-- So first, I grab the location_id and true_water_source_score columns from auditor_report.
SELECT location_id,true_water_source_score
FROM auditor_report;

-- I join the visits table to the auditor_report table. Make sure to grab subjective_quality_score, record_id and location_id.
SELECT
a.location_id AS audit_location,
a.true_water_source_score,
v.location_id AS visit_location,
v.record_id
FROM
auditor_report a
JOIN
visits v
ON a.location_id = v.location_id;

-- JOIN the visits table and the water_quality table, using the record_id as the connecting key.
SELECT
a.location_id AS audit_location,
a.true_water_source_score,
v.location_id AS visit_location,
v.record_id,
subjective_quality_score
FROM 
auditor_report a
JOIN
visits v
ON a.location_id = v.location_id
JOIN
water_quality wq
ON v.record_id = wq.record_id;

/*  Since it is a duplicate, I can drop one of the location_id columns.
 Let's leave record_id and rename the scores to surveyor_score and auditor_score to make it clear which scores we're looking at in the results set*/
SELECT
a.location_id AS location_id,
v.record_id,
a.true_water_source_score AS auditor_score,
wq.subjective_quality_score AS surveyor_score
FROM 
auditor_report a
JOIN
visits v
ON a.location_id = v.location_id
JOIN
water_quality wq
ON v.record_id = wq.record_id;

/* A good starting point is to check if the auditor's and exployees' scores agree. 
There are many ways to do it. I can have a WHERE clause and check if surveyor_score = auditor_score,
 or I can subtract the two scores and check if the result is 0 */
SELECT
a.location_id AS location_id,
v.record_id,
a.true_water_source_score AS auditor_score,
wq.subjective_quality_score AS surveyor_score
FROM 
auditor_report a
JOIN
visits v
ON a.location_id = v.location_id
JOIN
water_quality wq
ON v.record_id = wq.record_id
WHERE a.true_water_source_score = wq.subjective_quality_score;

/* I got 2505 rows right? Some of the locations were visited multiple times, so these records are duplicated here.
 To fix it, I set visits.visit_count= 1 in the WHERE clause */ 
SELECT
a.location_id AS location_id,
v.record_id,
a.true_water_source_score AS auditor_score,
wq.subjective_quality_score AS surveyor_score
FROM 
auditor_report a
JOIN
visits v
ON a.location_id = v.location_id
JOIN
water_quality wq
ON v.record_id = wq.record_id
WHERE v.visit_count = 1 AND
a.true_water_source_score = wq.subjective_quality_score;

/* With the duplicates removed I now get 1518. What does this mean considering the auditor visited 1620 sites? 
But that means that 102 records are incorrect. So let's look at those. You can do it by adding one character in the last query */
SELECT
a.location_id AS location_id,
v.record_id,
a.true_water_source_score AS auditor_score,
wq.subjective_quality_score AS surveyor_score
FROM 
auditor_report a
JOIN
visits v
ON a.location_id = v.location_id
JOIN
water_quality wq
ON v.record_id = wq.record_id
WHERE v.visit_count = 1 AND
a.true_water_source_score != wq.subjective_quality_score;

/* So, to do this, I need to grab the type_of_water_source column from the water_source table and call it survey_source,
 using the source_id column to JOIN. Also select the type_of_water_source from the auditor_report table, and call it auditor_source. */
SELECT
a.location_id AS location_id,
a.type_of_water_source AS auditor_source,
ws.type_of_water_source AS surveyor_source,
v.record_id,
a.true_water_source_score AS auditor_score,
wq.subjective_quality_score AS surveyor_score
FROM 
auditor_report a
JOIN
visits v
ON a.location_id = v.location_id
JOIN
water_quality wq
ON v.record_id = wq.record_id
JOIN water_source ws
ON ws.source_id = v.source_id
WHERE v.visit_count = 1 AND
a.true_water_source_score != wq.subjective_quality_score;

/* I JOIN the assigned_employee_id for all the people on our list from the visits table to our query. 
our query shows the shows the 102 incorrect records, so when I join the employee data, I can see which employees made these incorrect records. */
SELECT
a.location_id AS location_id,
v.record_id,
v.assigned_employee_id,
a.true_water_source_score AS auditor_score,
wq.subjective_quality_score AS surveyor_score
FROM 
auditor_report a
JOIN
visits v
ON a.location_id = v.location_id
JOIN
water_quality wq
ON v.record_id = wq.record_id
WHERE v.visit_count = 1 AND
a.true_water_source_score != wq.subjective_quality_score;

/* So I link the incorrect records to the employees who recorded them.
 The ID's don't help us to identify them. I have employees' names stored along with their IDs,
 so I wrote a query to fetch their names from the employees table instead of the ID's. */
SELECT
a.location_id AS location_id,
v.record_id,
e.employee_name,
a.true_water_source_score AS auditor_score,
wq.subjective_quality_score AS surveyor_score
FROM 
auditor_report a
JOIN 
visits v
ON a.location_id = v.location_id
JOIN
water_quality wq
ON v.record_id = wq.record_id
JOIN 
employee e
ON v.assigned_employee_id = e.assigned_employee_id
WHERE v.visit_count = 1 AND
a.true_water_source_score != wq.subjective_quality_score;

/* this query is massive and complex, so I save it as a CTE, so when I do more analysis,
 I can just call that CTE like it was a table. Call it something like Incorrect_records. */

WITH Incorrect_records AS(
SELECT
a.location_id AS location_id,
v.record_id,
e.employee_name,
a.true_water_source_score AS auditor_score,
wq.subjective_quality_score AS surveyor_score
FROM 
auditor_report a
JOIN 
visits v
ON a.location_id = v.location_id
JOIN
water_quality wq
ON v.record_id = wq.record_id
JOIN 
employee e
ON v.assigned_employee_id = e.assigned_employee_id
WHERE v.visit_count = 1 AND
a.true_water_source_score != wq.subjective_quality_score
)
SELECT *
FROM Incorrect_records;

-- Let's first get a unique list of employees from this table.
WITH Incorrect_records AS(
SELECT
a.location_id AS location_id,
v.record_id,
e.employee_name,
a.true_water_source_score AS auditor_score,
wq.subjective_quality_score AS surveyor_score
FROM 
auditor_report a
JOIN 
visits v
ON a.location_id = v.location_id
JOIN
water_quality wq
ON v.record_id = wq.record_id
JOIN 
employee e
ON v.assigned_employee_id = e.assigned_employee_id
WHERE v.visit_count = 1 AND
a.true_water_source_score != wq.subjective_quality_score
)
SELECT DISTINCT employee_name
FROM Incorrect_records;

/* Next, I calculate how many mistakes each employee made.
 So basically I count how many times their name is in Incorrect_records list, and then group them by name */
WITH Incorrect_records AS(
SELECT
a.location_id AS location_id,
v.record_id,
e.employee_name,
a.true_water_source_score AS auditor_score,
wq.subjective_quality_score AS surveyor_score
FROM 
auditor_report a
JOIN 
visits v
ON a.location_id = v.location_id
JOIN
water_quality wq
ON v.record_id = wq.record_id
JOIN 
employee e
ON v.assigned_employee_id = e.assigned_employee_id
WHERE v.visit_count = 1 AND
a.true_water_source_score != wq.subjective_quality_score
)
SELECT *
FROM Incorrect_records;

-- query to get a unique list of employees from this table.
WITH Incorrect_records AS(
SELECT
a.location_id AS location_id,
v.record_id,
e.employee_name,
a.true_water_source_score AS auditor_score,
wq.subjective_quality_score AS surveyor_score
FROM 
auditor_report a
JOIN 
visits v
ON a.location_id = v.location_id
JOIN
water_quality wq
ON v.record_id = wq.record_id
JOIN 
employee e
ON v.assigned_employee_id = e.assigned_employee_id
WHERE v.visit_count = 1 AND
a.true_water_source_score != wq.subjective_quality_score
)
SELECT DISTINCT employee_name,
COUNT(employee_name) AS number_of_mistakes
FROM Incorrect_records
GROUP BY employee_name;

-- I try to find all of the employees who have an above-average number of mistakes.
 
WITH error_count AS(
SELECT DISTINCT employee_name,
COUNT(employee_name) AS number_of_mistakes
FROM (
SELECT
a.location_id AS location_id,
v.record_id,
e.employee_name,
a.true_water_source_score AS auditor_score,
wq.subjective_quality_score AS surveyor_score
FROM 
auditor_report a
JOIN 
visits v
ON a.location_id = v.location_id
JOIN
water_quality wq
ON v.record_id = wq.record_id
JOIN 
employee e
ON v.assigned_employee_id = e.assigned_employee_id
WHERE v.visit_count = 1 AND
a.true_water_source_score != wq.subjective_quality_score
) AS incorrect_records
GROUP BY employee_name
)
SELECT *
FROM error_count;

-- I did a query to find the average number of mistakes employees made. 
WITH error_count AS(
SELECT DISTINCT employee_name,
COUNT(employee_name) AS number_of_mistakes
FROM (
SELECT
a.location_id AS location_id,
v.record_id,
e.employee_name,
a.true_water_source_score AS auditor_score,
wq.subjective_quality_score AS surveyor_score
FROM 
auditor_report a
JOIN 
visits v
ON a.location_id = v.location_id
JOIN
water_quality wq
ON v.record_id = wq.record_id
JOIN 
employee e
ON v.assigned_employee_id = e.assigned_employee_id
WHERE v.visit_count = 1 AND
a.true_water_source_score != wq.subjective_quality_score
) AS incorrect_records
GROUP BY employee_name
)
SELECT AVG(number_of_mistakes) as avg_error_count_per_empl
FROM error_count;

-- 3. Finaly a query to compare each employee's error_count with avg_error_count_per_empl. We will call this results set our suspect_list.
WITH error_count AS(
SELECT DISTINCT employee_name,
COUNT(employee_name) AS number_of_mistakes
FROM (
SELECT
a.location_id AS location_id,
v.record_id,
e.employee_name,
a.true_water_source_score AS auditor_score,
wq.subjective_quality_score AS surveyor_score
FROM 
auditor_report a
JOIN 
visits v
ON a.location_id = v.location_id
JOIN
water_quality wq
ON v.record_id = wq.record_id
JOIN 
employee e
ON v.assigned_employee_id = e.assigned_employee_id
WHERE v.visit_count = 1 AND
a.true_water_source_score != wq.subjective_quality_score
) AS incorrect_records
GROUP BY employee_name
)
SELECT
employee_name,
number_of_mistakes
FROM error_count
WHERE number_of_mistakes >  (SELECT AVG(number_of_mistakes) as avg_error_count_per_empl
FROM error_count);

-- Convert Incorrect_records to a view
CREATE VIEW Incorrect_records AS (
SELECT
a.location_id,
v.record_id,
e.employee_name,
a.true_water_source_score AS auditor_score,
wq.subjective_quality_score AS surveyor_score,
a.statements AS statements
FROM
auditor_report a
JOIN
visits v
ON a.location_id = v.location_id
JOIN
water_quality wq
ON v.record_id = wq.record_id
JOIN
employee e
ON e.assigned_employee_id = v.assigned_employee_id
WHERE
v.visit_count = 1
AND a.true_water_source_score != wq.subjective_quality_score);

SELECT * FROM incorrect_records;


-- convert the suspect_list to a CTE
WITH suspect_list AS(
SELECT
employee_name,
number_of_mistakes
FROM error_count
WHERE number_of_mistakes > (SELECT AVG(number_of_mistakes) as avg_error_count_per_empl FROM error_count)
) 
SELECT * 
FROM suspect_list;

-- Now we can filter that Incorrect_records view to identify all of the records associated with the four employees we identified.
WITH suspect_list AS(
SELECT
employee_name,
number_of_mistakes
FROM error_count
WHERE number_of_mistakes > (SELECT AVG(number_of_mistakes) as avg_error_count_per_empl FROM error_count)
)
SELECT employee_name, location_id, statements
FROM incorrect_records
WHERE employee_name IN (SELECT employee_name FROM suspect_list);

-- Filter the records that refer to "cash"
WITH suspect_list AS(
SELECT
employee_name,
number_of_mistakes
FROM error_count
WHERE number_of_mistakes > (SELECT AVG(number_of_mistakes) as avg_error_count_per_empl FROM error_count)
)
SELECT employee_name, location_id, statements
FROM incorrect_records
WHERE employee_name IN (SELECT employee_name FROM suspect_list)
AND statements LIKE "%cash%";

-- Check if there are any employees in the Incorrect_records table with statements mentioning "cash" that are not in our suspect list. This should be as simple as adding one word.
SELECT *
FROM incorrect_records
WHERE statements LIKE "%cash&";


