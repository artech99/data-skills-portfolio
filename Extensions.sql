hstore

Stores keys and values as a string
	• Values are stored in a single database column, but can be queried

CREATE EXTENSION hstore;

CREATE TABLE books (
	id serial pimary KEY
	,title TEXT
	,attributes hstore
	);


INSERT INTO books (title, attributes)
VALUES ('SQL for Data Science',
	'language=>English, page_cnt=>500, pub_year=>2021');
INSERT INTO books (title, attributes)
VALUES ('SQL for Data Science 2', 'language=>English, page_cnt=>600, pub_year=>2022');

SELECT title, attributes - > 'page_cnt' pc
FROM books;





JSON and JSONB

JSONB allows indexing, whereas JSON does not

CREATE TABLE customer_summary (
	id serial PRIMARY KEY
	,customer_doc jsonb
	);


INSERT INTO customer_summary (customer_doc)
VALUES (
	'{"customer_name":{"first_name":"Alice,
				"last_name":"Johnson"},
		"address":{"street":"5432 Port Ave",
			"city":"Boston",
"state":"MA"}
		"purchase_history":{
			"annual_purchase_value":[100,200,350], -- this is an array capturing 3 years
"lifetime_value":1500
			}
		}')
	}')


SELECT *
FROM customer_summary;




SELECT customer_doc->'customer_name'
FROM customer_summary;



SELECT customer_doc->'customer_name'->>'first_name'
FROM customer_summary;


