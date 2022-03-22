---- -------------- BASIC MATHS AND STATISTICS WITH SQL -----------------------
---------------- maths and datatype-----------
--The datatype returned for a calculation will vary depending on the operation and the 
--data type of the input numbers. In calculations with an operator between two 
--numbers—addition, subtraction, multiplication, and division—the data type returned
--follows this pattern:
-------•	Two integers return an integer.
-------•	A numeric on either side of the operator returns a numeric. 
-------•	Anything with a floating-point number returns a floating-point number of type
------------double precision.
--However, the exponentiation, root, and factorial functions are different.
--Each takes one number either before or after the operator and returns numeric 
--and floating-point types, even when the input is an integer. 

SELECT 24 + 18;
SELECT 100.45 - 56;
SELECT 12 * 5;
SELECT 13/3; ----division of one integer by another integer returns another interger(the quotient)

SELECT 13 % 3;-- this returns another integer but this time its the reminder.
SELECT 11 / 6 ::float; ---here we (use) cast(::) the result to float(decimal datatype)
---SELECT CAST (13 AS numeric(3,1)) / 3;

-----------------------EXPONENTIAL, ROOTS AND FACTORIALS---------------------
SELECT 3 ^ 4;  -- three raised of the power of 4
SELECT |/16; -------square root of 16
SELECT sqrt(16); --- another method of square root of 16
SELECT ||/ 8; ------- cube root of 8
SELECT ||/ 16;

SELECT POWER(27.0, (1/3.0)::float; -----cube-root of 27,
------this line of command can also be used for the nth root of any number notice we had to make the 
-----numbers look like decimal and also instruct postgre to return the answer as float i.e deimal

SELECT 4 !;   --- four factorial

------------------------- DOING MATHS ACCROSS TABLE ----------------
-- in the session, we shall be using the us census dataset we 
--earlier imported
--- as a quick reminder:
SELECT geo_name,
       state_us_abbreviation AS "st",
       p0010001 AS "Total Population",
       p0010003 AS "White Alone",
       p0010004 AS "Black or African American Alone",
       p0010005 AS "Am Indian/Alaska Native Alone",       p0010006 AS "Asian Alone",
       p0010007 AS "Native Hawaiian and Other Pacific Islander Alone",
       p0010008 AS "Some Other Race Alone",
       p0010009 AS "Two or More Races"
FROM us_counties_2010;
--- the 'AS' keyword help give the columns a more readable name 
---in form of alias in the result set. 

-----------ADDITION AND SUBTRACTION------------
SELECT geo_name,
       state_us_abbreviation AS "st",
       p0010003 AS "White Alone",
       p0010004 AS "Black Alone",
       p0010003 + p0010004 AS "Total White and Black"
FROM us_counties_2010;


SELECT geo_name,
       state_us_abbreviation AS "st",
       p0010001 AS "Total",
       p0010003 + p0010004 + p0010005 + p0010006 + p0010007
           + p0010008 + p0010009 AS "All Races",
       (p0010003 + p0010004 + p0010005 + p0010006 + p0010007
           + p0010008 + p0010009) - p0010001 AS "Difference"
FROM us_counties_2010
ORDER BY "Difference" DESC;


----------------21/06/2021--------------------	
			 
------- FINDING PERCENTAGES OF WHOLE--------------------------------
SELECT geo_name,
       state_us_abbreviation AS "st",
       ((p0010006 :: float / p0010001) ) * 100 AS "pct_asian"
FROM us_counties_2010
ORDER BY "pct_asian" DESC;
-------::float is written in one of the operators so that it doesn't return zero which is the quotient----
-----p0010006 is smaller than p0010001 which when it divides it, it will have 0...., and it'll *0 by 100 and return 0---			 
			 
SELECT geo_name,
       state_us_abbreviation AS "st",
	   round ((p0010006 :: numeric / p0010001) * 100, 1 ) AS "pct_asianround"

ORDER BY "pct_asian" DESC;




----- CALCULATING PERCENTAGE CHANGE---------
---we shall be creating a new table for this purpose
CREATE TABLE percent_change (
    department varchar(20),
    spend_2014 numeric(10,2),
    spend_2017 numeric(10,2)
);

INSERT INTO percent_change
VALUES
    ('Building', 250000, 289000),
    ('Assessor', 178556, 179500),
    ('Library', 87777, 90001),
    ('Clerk', 451980, 650000),
    ('Police', 250000, 223000),
    ('Recreation', 199000, 195000);

SELECT department,
       spend_2014,
       spend_2017,
       round( (spend_2017 - spend_2014) /
                    spend_2014 * 100, 1) AS "pct_change"
FROM percent_change;

---------- CALCULATING SUM AND AVERAGE ------------------------------
SELECT sum(p0010001) AS "County Sum",
       round(avg(p0010001), 2) AS "County Average"
FROM us_counties_2010;
----------If As county sum & county average are omitted, there'll be no specification of column names			 


----------- FINDING MEDIAN AND PERCENTILE------------
---- remember median is 50th percentile
--—percentile_cont(n) and percentile_disc(n)—handle are the functions
---for calculating percentile. Both functions are part of the 
---ANSI SQL standard and are present in PostgreSQL, Microsoft SQL Server,
---and other databases.
---The percentile_cont(n)(cont is continuous) function calculates percentiles as continuous
----values. That is, the result does not have to be one of the numbers in the 
----data set but can be a decimal value in between two of the numbers. This 
---follows the methodology for calculating medians on an even number of 
---values, where the median is the average of the two middle numbers. On the 
--other hand, percentile_disc(n) (disc is discrete) returns only discrete values. That is, the result 
---returned will be rounded to one of the numbers in the set.

CREATE TABLE percentile_test (
    numbers integer
);

INSERT INTO percentile_test (numbers) VALUES
    (1), (7), (10), (4), (15), (11);

SELECT
    percentile_cont(.5)
    WITHIN GROUP (ORDER BY numbers),
    percentile_disc(.5)
    WITHIN GROUP (ORDER BY numbers)
FROM percentile_test;			 


--The percentile_cont() function returned what we expect the median 
--to be: 8.5. But because percentile_disc() calculates discrete values, it reports 
--7, the last value in the first 50 percent of the numbers. Because the accepted 
--method of calculating medians is to average the two middle values in an 
--even-numbered set, use percentile_cont(.5) to find a median.

-------- MEDIAN USING THE CENSUS DATA-----------------------
SELECT sum(p0010001) AS "County Sum",
       round(avg(p0010001), 0) AS "County Average",
       percentile_cont(.5)
       WITHIN GROUP (ORDER BY p0010001) AS "County Median"
FROM us_counties_2010;

------------ FINDING OTHER QUARTILES WITH PERCENTILE FUNCTION --------
---  we can always find the 0.25 quartile, 0.75 quartile just as we did foe .50 quartile .
---- however, , entering values one at a time is laborious
--if you want to generate multiple cut points.
--Instead, you can pass values into percentile_cont() using an array,
--a SQL data type that contains a list of items.
-- quartiles

SELECT percentile_cont(array[.25, .5, .75])			 
       WITHIN GROUP (ORDER BY p0010001) AS "quartiles"
FROM us_counties_2010;

--In this example, we create an array of cut points by enclosing values 
--in a square bracket. Inside the square brackets, we provide 
--comma-separated values representing the three points at which to cut to 
--create four quartiles.

-- because we entered an array, POSTGRE returns array.
--the function unnest in the query below present the result unform of a row
SELECT unnest(
            percentile_cont(array[.25,.5,.75])
            WITHIN GROUP (ORDER BY p0010001)
            ) AS "quartiles"
FROM us_counties_2010;
			 
-------------- QUICK EXERCISE---------
---- find the quintiles and the deciles, presenting your result iun form of row

			 
-- quintiles
SELECT unnest(

	percentile_cont(array[.2,.4,.6,.])
       WITHIN GROUP (ORDER BY p001001) 
	)AS "quintiles"
FROM us_counties_2010;

-- deciles
SELECT ( 
			 percentile_cont(array[.1,.2,.3,.4,.5,.6,.7,.8,.9])
       WITHIN GROUP (ORDER BY p0010001)
	)AS "deciles"
FROM us_counties_2010;
			 
			 
			 
			 
			 
			 
			 
			 
			 
			 
			 






















-- quintiles
SELECT percentile_cont(array[.2,.4,.6,.8])
       WITHIN GROUP (ORDER BY p0010001) AS "quintiles"
FROM us_counties_2010;

-- deciles
SELECT percentile_cont(array[.1,.2,.3,.4,.5,.6,.7,.8,.9])
       WITHIN GROUP (ORDER BY p0010001) AS "deciles"
FROM us_counties_2010;

