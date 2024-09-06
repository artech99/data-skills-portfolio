/* Ordered Set Functions
	• String aggregate - if a NULL value appears in the data, string aggregate will ignore/remove all values in the row
	• CONCAT will return all other values except for the NULL
*/

/* Grouping Sets
Verbose solution
*/

WITH Aggregated_Adoptions
AS (
	SELECT YEAR(Adoption_Date) AS Year
		,MONTH(Adoption_Date) AS MONTH
		,COUNT(*) AS Monthly_Adoptions
	FROM Adoptions
	GROUP BY YEAR(Adoption_Date)
		,MONTH(Adoption_Date)
	)
SELECT *
FROM Aggregated_Adoptions
UNION ALL
SELECT Year
	,NULL -- NULL is included here so the results have the same number of columns; this is used instead of a string because NULL has no value AND no data type (that could cause a data type mismatch)
	,COUNT(*) AS Yearly_Adoptions
FROM Aggregated_Adoptions
GROUP BY Year
SELECT NULL -- NULL is included here so the results have the same number of columns
	,NULL -- NULL is included here so the results have the same number of columns
	,COUNT(*) AS Total_Adoptions
FROM Aggregated_Adoptions
GROUP BY ();-- this is the same as GROUP'ing by the entire table and is generally omitted; it is included here to have a UNION between the same number of columns


/* More elegant solutions
total adoptions by month
*/

SELECT YEAR(Adoption_Date) AS Year
	,MONTH(Adoption_Date) AS MONTH
	,COUNT(*) AS Monthly_Adoptions
FROM Adoptions
GROUP BY GROUPING SETS((
			YEAR(Adoption_Date)
			,MONTH(Adoption_Date)
			));-- be sure to use both inner and outer parentheses if items in parentheses should be evaluated together as a single set

-- total adoptions by year, total adoptions by month, and total adoptions
SELECT YEAR(Adoption_Date) AS Year
	,MONTH(Adoption_Date) AS MONTH
	,COUNT(*) AS Monthly_Adoptions
FROM Adoptions
GROUP BY GROUPING SETS((
			YEAR(Adoption_Date)
			,MONTH(Adoption_Date)
			), YEAR(Adoption_Date), ());
	, MONTH((Adoption_Date), YEAR(Adoption_Date), ());

-- replace NULL values with label for groupings
SELECT COALESE(Species, 'All') AS Species -- replaces NULL values of Species as 'All'
	,CASE 
		WHEN GROUPING(Breed) = 1 -- sets value to 'true' when data is for a grouping set versus a NULL value
			THEN 'All' -- labels grouping set values as 'All'
		ELSE Breed
		END AS Breed
	,GROUPING(Breed) AS All_Breeds -- creates value for grouping set
	,Count(*) AS Number_of_Animals
FROM Animals
GROUP BY GROUPING SETS(Species, Breed, ())
ORDER BY Species, Breed;
