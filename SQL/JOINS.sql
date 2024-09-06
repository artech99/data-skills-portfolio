/* Chiastic Order
	• Enforce JOIN ORDER using Chiastic Order
*/


-- return all rows where there is a match in all 3 tables
SELECT *
FROM Animals A
LEFT JOIN Adoptions AD ON AD.Name = A.Name
	AND AD.Species = A.Species
INNER JOIN Persons P ON P.Email = AD.Adopter_Email

-- return all rows in Animals table and matching rows in Adoptions and Persons tables (performance hit; not logically correct)
SELECT *
FROM Animals A
LEFT JOIN Adoptions AD ON AD.Name = A.Name
	AND AD.Species = A.Species
LEFT JOIN Persons P ON P.Email = AD.Adopter_Email

-- return all rows in Animals table and matching rows in Adoptions and Persons tables (Chiastic order - uses encapsulation and is logically correct)
SELECT *
FROM Animals A
LEFT JOIN (
	Adoptions AD INNER JOIN Persons P ON P.Email = AD.Adopter_Email
	) ON AD.Name = A.Name
	AND AD.Species = A.Species



/* ANTI-JOINS
	• Used to select rows where something does NOT exist

NOT EXIST
*/

/* Verbose solution 
select animals who have not been adopted
*/

SELECT DISTINCT AN.Name
	,AN.Species
FROM Animals AS AN
LEFT OUTER JOIN Adoptions AS AD ON AD.Name = AN.Name
	AND AD.Species = AN.Species
WHERE AD.Name IS NULL;


/* More elegant solution
select animals who have not been adopted
*/

SELECT Name
	,Species
FROM Animals AS AN
WHERE NOT EXISTS (
		SELECT NULL
		FROM Adoptions AS AD
		WHERE AD.Name = AN.Name
			AND AD.Species = AN.Species
		);

/* Note: When using EXISTS, Inner Query can use SELECT NULL, SELECT *, or any other SELECT statement. It does not affect the results of the Outer Query. */

-- select animals who have not been adopted 
SELECT Name, Species
FROM Animals
EXCEPT
SELECT Name, Species
FROM Adoptions;

-- select breeds that have not been adopted
SELECT Species, Breed
FROM Animals
EXCEPT
SELECT AN.Species, AN.Name
FROM Animals AS AN
INNER JOIN Adoptions AS AD ON AD.Name = AN.Name
	AND AD.Species = AN.Species



/* SELF JOIN
	• Used when a table references data within itself
*/
	
-- when using effective dated tables, alias a table and reference it in a subquery with a different alias to select the most recent value for a given field value
WHERE a.effdt = (
		SELECT max(a1.effdt)
		FROM ps_name a1
		WHERE a1.emplid = a.emplid
			AND a1.name_type = a.name_type
			AND a1.effdt <= sysdate
		);


-- select all rows where adopter adopted 2 animals on the same day
SELECT A1.Adopter_Email
	,A1.Adoption_Date
	,A1.Name AS Name1
	,A1.Species AS Species1
	,A2.Name AS Name2
	,A2.Species AS Species2
FROM Adoptions AS A1
INNER JOIN Adoptions AS A2 ON A1.Adopter_Email = A2.Adopter.Email -- identify same adopter
	AND A1.Adoption_Date = A2.Adoption_Date -- select same adoption date
	AND (
		(
			A1.Name = A2.Name
			AND A1.Species > A2.Species
			) -- animals with same name must be a different species
		OR (
			A1.Name > A2.Name
			AND A1.Species = A2.Species
			) -- animals of the same species must have different names
		OR (
			A1.Name > A2.Name
			AND A1.Species <> A2.Species
			) -- animals may have different name and be a different species
		)
ORDER BY A1.Adopter_Email
	,A1.Adoption_Date


--given a table with employee ID, first name, last name, and manager ID, create a query that returns employee first and last name, and manager first and last name
SELECT e.firstName
	,e.lastName
	,e.title
	,m.firstName AS MgrFirstName
	,m.lastName AS MgrLastName
FROM employee e
INNER JOIN employee m ON e.managerID = m.managerID


/* LATERAL JOIN
	• Allows you to create a computation in a subquery that is reused in the outer query	
*/

/* CROSS APPLY
select the last 3 vaccinations per animal (T-SQL); do not return animals who were never vaccinated)
*/

SELECT A.Name
	,A.Species
	,A.Primary_Color
	,A.Breed
	,Last_Vaccinations.*
FROM Animals AS A
CROSS APPLY (
	SELECT V.Vaccine
		,V.Vaccination_time
	FROM Vaccinations AS V
	WHERE V.Name = A.Name
		AND V.Species = A.Species
	ORDER BY V.Vaccination_Time DESC OFFSET 0 ROWS FETCH NEXT 3 ROW ONLY
	) AS Last_Vaccinations;

/* OUTER APPLY
select the last 3 vaccinations per animal (T-SQL); return animals who were never vaccinated) 
*/

SELECT A.Name
	,A.Species
	,A.Primary_Color
	,A.Breed
	,Last_Vaccinations.*
FROM Animals AS A
OUTER APPLY (
	SELECT V.Vaccine
		,V.Vaccination_time
	FROM Vaccinations AS V
	WHERE V.Name = A.Name
		AND V.Species = A.Species
	ORDER BY V.Vaccination_Time DESC OFFSET 0 ROWS FETCH NEXT 3 ROW ONLY
	) AS Last_Vaccinations;


--RECURSIONS

/* UNION ALL
generate days of a year
*/

WITH Days_of_2024 (Day)
AS (
	SELECT CAST('20240101' AS DATE)
	
	UNION ALL
	
	SELECT DATEADD(DAY, 1, Day)
	FROM Days_of_2024
	WHERE Day < CAST('20241231' AS DATE)
	)
SELECT *
FROM Days_of_2024
ORDER BY Day
OPTION (MAXRECURSION 365);-- SQL Server has a max recursion depth of 100, unless explicitly defined

/* RECURSIVE
	• Refers to a recursive CTE
*/

-- create Fibonacci series -- 
WITH RECURSIVE f (m, n)
AS (
	SELECT 0	 ,1
	UNION ALL
	SELECT m + n, m + n + n
	FROM f
	WHERE m + n + n <= 1000
	)
SELECT *
FROM f;
