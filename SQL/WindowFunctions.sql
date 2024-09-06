/* Window Functions allow you to perform a query against a subset of data
	• Any WHERE statement would be executed before the windows function. So if you want to filter based on a value in the Windows function, put the Windows function in a CTE.
	• Syntax: FUNCTION() OVER(PARTITION BY [...] {works similar to a GROUP BY clause} ORDER BY [...] FRAME [...] {optionally limits data set; ex. limit to current row}


OVER
	• Used with Windows functions to aggregate results based on a given value; works similar to GROUP BY
*/

/* Verbose solution
-select animals admitted after given date, total # of animals
*/

SELECT Species
	,Name
	,Primary_Color
	,Admission_Date
	,(
		SELECT Count(*)
		FROM Animals
		WHERE Admission_Date >= '2024-04-05'
		) AS Number_of_Animals
FROM Animals
WHERE Admission_Date >= '2024-04-05'
ORDER BY Admission_Date;

/* More elegant solution
select animals admitted after given date, total # of animals
*/

SELECT Species
	,Name
	,Primary_Color
	,Admission_Date
	,Count(*) OVER () AS Number_of_Animals
FROM Animals
WHERE Admission_Date >= '2024-04-05'
ORDER BY Admission_Date;



PARTITION BY
	• A subclause of OVER clause used to group results into sets

SELECT account_id
	,occurred_at
	,total_amt_usd
	,NTILE(100) OVER (
		PARTITION BY account_ID ORDER BY total_amt_usd
		) AS total_percentile
FROM orders
ORDER BY account_id



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



/* Verbose solution
select animals, and total # of animals by species 
*/
	
SELECT A1.Species
	,A1.Name
	,A1.Primary_Color
	,A1.Admission_Date
	,(
		SELECT Count(*)
		FROM Animals AS A2
		WHERE A1.Species = A2.Species
		) AS Number_of_Species_Animals
FROM Animals AS A1
ORDER BY A1.Species
	,A1.Admission_Date;

/* Better solution
select animals, and total # of animals by species 
*/

SELECT A.Species
	,A.Name
	,A.Primary_Color
	,A.Admission_Date
	,Species_Counts.Number_of_Species_Animals
FROM Animals AS A
INNER JOIN (
	SELECT Species
		,Count(*) AS Number_of_Species_Animals
	FROM Animals
	GROUP BY Species
	) AS Species_Counts
ORDER BY A.Species
	,A.Admission_Date;

/* More elegant solution
select animals, and total # of animals by species 
*/

SELECT Species
	,Name
	,Primary_Color
	,Admission_Date
	,Count(*) OVER (PARTITION BY Species) AS Number_of_Species_Animals
FROM Animals
ORDER BY A1.Species
	,A1.Admission_Date;


ROW NUMBER
	• Assigns row numbers to results in a data set
	• PARTITION BY, ORDER BY, and FRAME are optional


WITH CustOrders
AS (
	SELECT OrderNum
		,OrderDate
		,CustName
		,ProdCategory
		,ProdName
		,[Order Total] ROW_NUMBER() OVER (
			PARTITION BY ProdCategory ORDER BY [Order Total] DESC
			) AS Row
	FROM [Red30Tech].[dbo].[OnlineRetailSales$]
	)

SELECT OrderNum
	,OrderDate
	,CustName
	,ProdCategory
	,ProdName
	,[Order Total]
FROM CustOrders
WHERE CustName = 'Boehm Inc.'
	AND Row <= 3
ORDER BY ProdCategory
	,[Order Total]



/* RANK
	• Assigns a rank to each row based on the column value; skips values for two or more positions having the same rank.
	• Similar to ROW_NUMBER, except ties are given the same rank. The next sequential number(s) is then skipped.
	• PARTITION BY, ORDER BY, and FRAME are optional
	
	
DENSE RANK
	• Assigns a rank to each row based on the column value; does not skip values if two or more positions have the same value.
*/	

SELECT id
	,account_id
	,total
	,RANK() OVER (
		PARTITION BY account_id ORDER BY total DESC
		) AS total_rank
FROM orders



SELECT id
	,account_id
	,DATE_TRUNC('year', occurred_at) AS year
	,DENSE_RANK() OVER account_year_window AS dense_rank
	,total_amt_usd
	,SUM(total_amt_usd) OVER account_year_window AS sum_total_amt_usd
	,COUNT(total_amt_usd) OVER account_year_window AS count_total_amt_usd
	,AVG(total_amt_usd) OVER account_year_window AS avg_total_amt_usd
	,MIN(total_amt_usd) OVER account_year_window AS min_total_amt_usd
	,MAX(total_amt_usd) OVER account_year_window AS max_total_amt_usd
FROM orders WINDOW account_year_window AS (
		PARTITION BY account_id ORDER BY DATE_TRUNC('year', occurred_at)
		)


/* LEAD
	• Retrieves values from rows that follow the selected row
	• Syntax: LEAD([Column],Offset#)
		○ Offset tells SQL how many rows to go back; default value is 1 if not otherwise specified
		○ ORDER BY is required
		○ PARTITION BY and FRAME are optional
*/
	
SELECT occurred_at
	,total_amt_usd
	,LEAD(total_amt_usd) OVER (
		ORDER BY occurred_at
		) AS lead
	,LEAD(total_amt_usd) OVER (
		ORDER BY occurred_at
		) - total_amt_usd AS lead_difference
FROM (
	SELECT occurred_at
		,SUM(total_amt_usd) AS total_amt_usd
	FROM orders
	GROUP BY 1
	) sub


	
/* LAG
	• Retrieves values from rows that precede the selected row
	• Syntax: LAG([Column],Offset#)
		○ Offset tells SQL how many rows to go back; default value is 1 if not otherwise specified
		○ ORDER BY is required
		○ PARTITION BY and FRAME are optional
*/
	
WITH OrderByDays
AS (
	SELECT OrderDate, Sum(Quantity) AS Tot_Day
	FROM [Red30Tech].[dbo].[OnlineRetailSales$]
	WHERE ProdCategory = 'Drones'
	GROUP BY OrderDate
	)

SELECT OrderDate
	,Tot_Day LAG(Tot_Day, 1) OVER (
		ORDER BY OrderDate ASC
		) AS 5 thPrevOrder
	,LAG(Tot_Day, 2) OVER (
		ORDER BY OrderDate ASC
		) AS 4 thPrevOrder
	,LAG(Tot_Day, 3) OVER (
		ORDER BY OrderDate ASC
		) AS 3 rdPrevOrder
	,LAG(Tot_Day, 4) OVER (
		ORDER BY OrderDate ASC
		) AS 2 ndPrevOrder
	,LAG(Tot_Day, 5) OVER (
		ORDER BY OrderDate ASC
		) AS 1 stPrevOrder
FROM OrderByDays



/* BETWEEN
	• Allows you to select values (numbers, text, or dates) within a specified range
*/
	
-- # vaccinations per year,  Avg # vaccinations in previous 2 years, % diff from current year and 2 yr avg
WITH Annual_Vaccinations_With_Previous_2_Year_Average
AS (
	SELECT CAST(DATE_PART('Year', Vaccination_time) AS INT) AS Year
		,COUNT(*) AS Number_of_Vaccinations
	FROM Vaccinations
	GROUP BY DATE_PART('Year', Vaccination_time)
	)
	,Annual_Vaccinations_With_Previous_2_Year_Average
AS (
	SELECT *
		,CAST(AVG(Number_of_Vaccinations) OVER (
				ORDER BY Year RANGE BETWEEEN 2 PRECEEDING
					AND 1 PRECEEDING
				) AS DECIMAL(5, 2)) AS Previous_2_Years_Average
	FROM Annual_Vaccinations
	)

SELECT *
	,CAST((100 * Number_of_Vaccinations / Previous_2_Years_Average) AS DECIMAL(5, 2)) AS Percent_Change
FROM Annual_Vaccinations_With_Previous_2_Year_Average
ORDER BY Year;



-- UNBOUNDED PRECEDING

SELECT MIN(Z) OVER W AS MIN_Z
	,MAX(Z) OVER W AS MAX_Z
FROM TABLE WINDOW W AS (
		PARTITION BY X ORDER BY Y ROWS BETWEEN UNBOUNDED PRECEDING
				AND CURRENT ROW
		);
