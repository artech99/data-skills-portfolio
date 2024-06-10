RIGHT

-- select the domain of a website
SELECT RIGHT(website, 3) AS website_type
	,count(*)
FROM accounts
GROUP BY website_type



LEFT

SELECT LEFT(name, 1) AS first_char
	,count(*)
FROM accounts
GROUP BY first_char
