/*
1: Write a query to retrieve details of all appointments along with the physician's and 
patient's names.

 -- INNER JOIN
 */

SELECT
	a.AppointmentID AS appointmentid,
	ph."Name" AS physician_name,
	p."Name" AS patient_name
FROM
	Appointment a
INNER JOIN Physician ph ON a.Physician = ph."EmployeeID"
INNER JOIN Patient p ON a.Patient = p.SSN;


/*
2: Retrieve all nurses and their on-call schedules, including those who may not have
any on-call assignments.

-- LEFT JOIN
*/

SELECT 
	*
FROM 
	Nurse n
LEFT JOIN On_Call o ON n.EmployeeID = o.Nurse;


/*
3. Show the number of procedures each physician is trained in, but only show physicians 
who are trained in more than 2 procedures.

-- GROUP BY with HAVING clause
*/

SELECT 
    ph.name AS physician_name,
    COUNT(t.t=Treatment) AS trained_in
FROM 
    trained_in t
INNER JOIN Physician ph ON t.Physician = ph.EmployeeID
GROUP BY 
    ph.name
HAVING 
    COUNT(t.Treatment) > 2;


/*
4. Retrieve the name of the patient and the details of the most expensive procedure they
underwent during their stay, including the procedure code and cost.
*/

-- WHERE
SELECT
		p.Name AS PatientName,
		pt.Code AS ProcedureCode,
		pt.Name AS ProcedureName,
		pt.Cost AS ProcedureCost
FROM Undergoes u
INNER JOIN Patient p ON u.Patient = p.SSN
INNER JOIN Proceduretable pt ON u.ProcedureCode = pt.Code
WHERE 
    pt.Cost = (
        SELECT MAX(cost) FROM Proceduretable
	);


-- SELECT FROM - SUBQUERY
SELECT 
	TOP(1) PatientName,
	ProcedureCode,
	ProcedureName,
	ProcedureCost
FROM (
	SELECT
		p.Name AS PatientName,
		pt.Code AS ProcedureCode,
		pt.Name AS ProcedureName,
		pt.Cost AS ProcedureCost
	FROM Undergoes u
	INNER JOIN Patient p ON u.Patient = p.SSN
	INNER JOIN Proceduretable pt ON u.ProcedureCode = pt.Code
	) AS sub_query
ORDER BY ProcedureCost DESC;


/*
5: List all physicians who have prescribed a medication "Awakin"
in its description.

-- WHERE Subquery
*/

SELECT
    ph.name AS physician_name
FROM 
    Prescribes pr
INNER JOIN Physician ph ON pr.Physician = ph.EmployeeID
WHERE 
    pr.Medication = (SELECT code FROM medication WHERE name = 'Awakin');


/*
6: Write a query to list all physicians and nurses, combining their names in a single result set.

-- UNION
*/

SELECT
	Name,
	'Physician' AS Role
FROM
	Physician
UNION
SELECT
	Name,
	'Nurse' AS Role
FROM
	Nurse;


/*
7. Use a CTE to list all nurses who assisted in procedures, along with the number of
procedures they assisted in.

--  CTEs (Common Table Expressions)
*/

WITH Nurse_Assist AS (
    SELECT
        n.Name AS nurse_name,
        COUNT(u.AssistingNurse) AS num_procedures
    FROM 
        Undergoes u
    INNER JOIN Nurse n ON u.AssistingNurse = n.EmployeeID
    GROUP BY
        n.Name
)
SELECT
    nurse_name,
    num_procedures
FROM
    Nurse_Assist;



/*
8: Write a query to classify physicians based on the number of procedures they are trained
in (<3: 'Basic', 3-5: 'Intermediate', >5: 'Advanced').

-- CASE
*/

SELECT 
    ph.Name AS physician_name,
    COUNT(t.Treatment) AS trained_in,
    CASE 
        WHEN COUNT(t.treatment) < 3 THEN 'Basic'
        WHEN COUNT(t.treatment) BETWEEN 3 AND 5 THEN 'Intermediate'
        ELSE 'Advanced'
    END AS classification
FROM 
    Trained_In t
INNER JOIN Physician ph ON t.Physician = ph.EmployeeID
GROUP BY 
    ph.name;


/*
9: Retrieve all patients, showing their primary care physician (PCP). 
If a PCP is not assigned, display "No PCP".

--  COALESCE
*/

SELECT 
    p.Name AS patient_name,
    COALESCE(ph.Name, 'No PCP') AS pcp_name
FROM 
    Patient p
LEFT JOIN Physician ph ON p.PCP = ph.EmployeeID;


/*
10: Create a view to simplify the retrieval of appointment information,
including the patient's and physician's names and the appointment start time.

-- VIEWS
*/

CREATE VIEW Appointment_Info AS
SELECT
    a.AppointmentID,
    p.Name AS patient_name,
    ph.Name AS physician_name,
    a."Start" AS start_dt_time,
    a."End" AS end_dt_time
FROM
	Appointment a
INNER JOIN Patient p ON a.Patient = p.SSN
INNER JOIN Physician ph ON a.Physician = ph.EmployeeID;

SELECT * FROM Appointment_Info;


/*
11: Write a stored procedure that takes a physician's ID and retrieves all procedures that physician has performed.

-- STORED PROCEDURES
*/

CREATE PROCEDURE GetPhysicianProcedures
    (@physician_id INT)
AS
BEGIN
	SELECT
		pt.Code AS ProcedureCode,
		pt.Name AS ProcedureName,
		pt.Cost AS ProcedureCost,
		u.Date AS procedure_date
	FROM 
		Undergoes u
	INNER JOIN Proceduretable pt ON u.ProcedureCode = pt.Code
    WHERE 
        u.Physician = @physician_id;
END;


EXEC GetPhysicianProcedures @physician_id = 3;


/*
11: Create an index on the Stay table's Room column to optimize queries that search by room number.

-- INDEXES
*/

CREATE INDEX idx_room ON Stay(Room);

SELECT 
	Room
FROM
	Stay;