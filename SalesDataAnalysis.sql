
--Inspecting data
select * from sales_data_sample

--Checking unique  --(gives an idea of the dataset)
select distinct STATUS from sales_data_sample --> shows unique status's which can be easy to plot  (NTP)
select distinct YEAR_ID from sales_data_sample --> shows the date range in the dataset
select distinct PRODUCTLINE from sales_data_sample --> shows how many products are there (here 7 products)  (NTP)
select distinct COUNTRY from sales_data_sample --> how many countries are there  (NTP)
select distinct DEALSIZE from sales_data_sample --> NTP  (medium,largze and small)
select distinct TERRITORY from sales_data_sample  --> NTP

--ANALYSIS--

--1) Grouping data by product line [ (aggregating sales across the product) when we introduce agg func group by comes and order by the position]

select PRODUCTLINE , SUM(SALES) AS REVENUE
from sales_data_sample
GROUP BY PRODUCTLINE
ORDER BY 2 DESC

--FINDING THE YEAR THEY MADE MOST SALES
SELECT YEAR_ID,SUM(SALES) AS REVENUE
FROM sales_data_sample
GROUP BY YEAR_ID
ORDER BY 2 DESC

--we find that 2005 is the lowest so we dig deeper by doing (distinct months) values in year 2003							--EDA 1
select distinct MONTH_ID from sales_data_sample
where YEAR_ID = 2005

--we find that they operated only 5 months compared lesser to other years where they operated the whole year so less revenue    -- EDA 2

--FINDING THE YEAR THEY MADE MOST SALES (PRODUCT-WISE)
SELECT YEAR_ID, PRODUCTLINE,SUM(SALES) AS REVENUE
FROM sales_data_sample
GROUP BY YEAR_ID, PRODUCTLINE
ORDER BY 3 DESC

--Most revenue across dealsize( small, medium,large)
SELECT DEALSIZE,SUM(SALES) AS REVENUE
FROM sales_data_sample
GROUP BY DEALSIZE
ORDER BY 2 DESC

--Best sales that was achieved based on month for a specific year and how much ?[ ALSO DOING COUNT OF NUMBER OF ORDERS]
SELECT MONTH_ID,SUM(SALES) AS REVENUE, COUNT(ORDERNUMBER) AS SOLD
FROM sales_data_sample
WHERE YEAR_ID = 2004  --> CHANGING YEAR ACCORDINGLY
GROUP BY MONTH_ID
ORDER BY 2 DESC

--FOUND NOVEMEBER TO BE A GOOD SALES MONTH --LETS CHECK FOR 2004 AND FOUND NOVEMEBER					

--Lets check which product sells the the most in november

SELECT MONTH_ID, PRODUCTLINE, COUNT(ORDERNUMBER) AS SOLD
FROM sales_data_sample
WHERE YEAR_ID = 2003 AND MONTH_ID = 11  --> CHANGE YEAR ACCORDINGLY
GROUP BY MONTH_ID, PRODUCTLINE
ORDER BY 2 DESC

----2) RFM ANALYSIS[ recency frequency monetary that uses past purchase behaviour to segment customers based on 3 metrics

--Finding out who is the Best customer 

SELECT 
	CUSTOMERNAME,
	SUM(SALES) AS TOTAL_REVENUE,
	AVG(SALES) AS AVG_REVENUE,
	MAX(ORDERDATE) AS LAST_ORDER_DATE,  
	COUNT(ORDERNUMBER) AS SOLD
FROM sales_data_sample
GROUP BY CUSTOMERNAME
ORDER BY 2 DESC

SELECT 
	CUSTOMERNAME,
	SUM(SALES) AS TOTAL_REVENUE,
	AVG(SALES) AS AVG_REVENUE,
	MAX(ORDERDATE) AS CUST_LASTORD_DATE,  
	COUNT(ORDERNUMBER) AS SOLD,
	(select MAX(ORDERDATE)FROM sales_data_sample)AS TAB_LASTORD_DATE --- > DATASET LAST ORDER DATE
FROM sales_data_sample
GROUP BY CUSTOMERNAME
ORDER BY 2 DESC

--WE DIFFERENCE  THE ABOVE TWO DATES TO GET ----  >     R E C E N C Y



SELECT 
	CUSTOMERNAME,
	SUM(SALES) AS TOTAL_REVENUE,
	AVG(SALES) AS AVG_REVENUE,
	MAX(ORDERDATE) AS CUST_LASTORD_DATE,  ----> CUSTOMER LAST ORDER DATE
	COUNT(ORDERNUMBER) AS SOLD,
	(select MAX(ORDERDATE)FROM sales_data_sample)AS TAB_LASTORD_DATE, --- > DATASET LAST ORDER DATE
	DATEDIFF(DD, MAX(ORDERDATE),(select MAX(ORDERDATE)FROM sales_data_sample))AS RECENCY -------> CUSTOMER RETENTION RECENCY FACTOR
FROM sales_data_sample
GROUP BY CUSTOMERNAME

	
--> We are now making a 4 buckets inside a package [NTILE] that access a window function using CTE 
--For Ntile function ORDER BY clause is required and partition by is optional by distributing rows into specified groups
--NTILE(2) distributes 10 tiles as 2 groups with 5 each


;WITH RFM as    --->Never forget Semicolon
(
SELECT 
	CUSTOMERNAME,
	SUM(SALES) AS TOTAL_REVENUE,
	AVG(SALES) AS AVG_REVENUE,
	MAX(ORDERDATE) AS CUST_LASTORD_DATE,  ----> CUSTOMER LAST ORDER DATE
	COUNT(ORDERNUMBER) AS SOLD,
	(select MAX(ORDERDATE)FROM sales_data_sample)AS TAB_LASTORD_DATE, --- > DATASET LAST ORDER DATE
	DATEDIFF(DD, MAX(ORDERDATE),(select MAX(ORDERDATE)FROM sales_data_sample))AS RECENCY -------> CUSTOMER RETENTION RECENCY FACTOR
FROM sales_data_sample
GROUP BY CUSTOMERNAME
)
select r.*,  --> STEP 2: create use that object
	NTILE(4) OVER (order by RECENCY DESC) AS RFM_RECENCY,
	NTILE(4) OVER (order by SOLD) AS RFM_FREQUENCY,
	NTILE(4) OVER (order by AVG_REVENUE) AS RFM_MONETARY
from RFM r   --> STEP 1: create an object for RFM
ORDER BY 4 DESC

--IM NOW CREATING AN ALIAS FOR THE BUCKETS

;WITH RFM as    --->Never forget Semicolon
(
SELECT 
	CUSTOMERNAME,
	SUM(SALES) AS TOTAL_REVENUE,
	AVG(SALES) AS AVG_REVENUE,
	MAX(ORDERDATE) AS CUST_LASTORD_DATE,  ----> CUSTOMER LAST ORDER DATE
	COUNT(ORDERNUMBER) AS SOLD,
	(select MAX(ORDERDATE)FROM sales_data_sample)AS TAB_LASTORD_DATE, --- > DATASET LAST ORDER DATE
	DATEDIFF(DD, MAX(ORDERDATE),(select MAX(ORDERDATE)FROM sales_data_sample))AS RECENCY -------> CUSTOMER RETENTION RECENCY FACTOR
FROM sales_data_sample
GROUP BY CUSTOMERNAME
),				
RFM_CALC AS		
(
select r.*,  --> STEP 2: create use that object
	NTILE(4) OVER (order by RECENCY DESC) AS RFM_RECENCY,
	NTILE(4) OVER (order by SOLD) AS RFM_FREQUENCY,
	NTILE(4) OVER (order by AVG_REVENUE) AS RFM_MONETARY
from RFM r   --> STEP 1: create an object for RFM
)
SELECT c.*
from RFM_CALC c				


--What Products are most often sold together

SELECT ORDERNUMBER, COUNT(*) AS RN
FROM sales_data_sample
WHERE STATUS='Shipped'				
GROUP BY ORDERNUMBER


