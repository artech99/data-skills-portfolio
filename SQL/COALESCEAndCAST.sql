COALESCE
	• Replaces null values with user defined values


SELECT COALESCE(o.id, a.id) AS missing_accountID
	,COALESCE(o.account_id, o.account_ID) AS o.account_ID
	,*
FROM accounts a
LEFT JOIN orders o ON a.id = o.account_id
WHERE o.total IS NULL;


SELECT COALESCE(o.standard_qty, 0) standard_qty
	,COALESCE(o.poster_qty, 0) AS poster_qty
	,COALESCE(o.gloss_qty, 0) AS gloss_qty
	,COALESCE(o.standard_amt_usd, 0) AS standard_amt_usd
	,COALESCE(o.poster_amt_usd, 0) AS poster_amt_usd
	,COALESCE(o.gloss_amt_usd, 0) AS gloss_amt_usd
	,*
FROM accounts a
LEFT JOIN orders o ON a.id = o.account_id
WHERE o.total IS NULL;



CAST
	• Allows you to apply a specific data type and/or format to a value

-- select each month's total adoptions as a percentage of the annual adoptions; round to 2 decimal places
WITH Monthly_Grouped_Adoptions
AS (
	SELECT DATE_PART('Year', Adoption_Date) AS Year
		,DATE_PART('Month', Adoption_Date) AS Month
		,SUM(Adoption_Fee) AS Month_Total
	FROM Adoptions
	GROUP BY DATE_PART('Year', Adoption_Date)
		,DATE_PART('Month', Adoption_Date)
	)

SELECT *
	,CAST(100 * Month_Total / SUM(Month_Total) OVER (PARTITION BY Year) AS DECIMAL(5, 2)) AS Annual_Percent
FROM Monthly_Grouped_Adoptions
ORDER BY Year, Month



SELECT COALESCE(CAST(YEAR(V.Vaccination_Time) AS VARHCAR(10)), 'All_Years') AS Year
	,-- Year is CAST as a varchar so that the 'date' can be replaced by a string for NULLs; otherwise you'll get an error that data type does not match
	COALESCE(V.Species, 'All Species') AS Species
	,COALESE(V.Email, 'All Staff') AS Staff_Member
	,CASE 
		WHEN GROUPING(V.Email) = 0
			THEN MAX(P.First_Name) -- since there will be only one row (per person), MAX is fine and is only used to return the result as an aggregate
		ELSE '' -- return a blank value for the aggregate
		END AS First_Name
	,-- dummy aggregate created to prevent SQL error and allow aggregation by Email
	CASE 
		WHEN GROUPING(V.Email) = 0
			THEN MAX(P.Last_Name)
		ELSE ''
		END AS Last_Name
	,-- dummy aggregate
	COUNT(*) AS Total_Vaccinations
FROM Vaccinations V
INNER JOIN PERSON P ON V.Email = P.Email
GROUP BY GROUPING SETS(YEAR(V.Vaccination_Time), V.Species, (
			V.Species
			,YEAR(V.Vaccination_Time)
			) P.Email, (
			P.Email
			,V.Species
			), ())
ORDER BY Year
	,Species
	,First_Name
	,Last_Name;