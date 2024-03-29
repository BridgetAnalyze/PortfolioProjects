--1.Selecting data based on constraints -Movies that have "Behind the scenes" added

SELECT * FROM Product_Data Where special_features LIKE '%Behind%' and inventory_id  is not NULL; 

--2. Aggregation Functions and Grouping

--To find if more rental is charged for those which replacement cost is higher
--Pulling stats about replacement cost

SELECT replacement_cost,
MIN(rental_rate) AS cheapest_rate,
MAX(rental_rate) AS highest_rate,
AVG(rental_rate) AS average_rate
FROM Product_Data
GROUP BY replacement_cost
ORDER BY replacement_cost

--3. Narrowing down this aggregation
--Finding customers that have less than 5 rentals

SELECT 
	customer_id ,
	COUNT(rental_id ) AS 
	rented 
FROM Rental_Data
GROUP BY
	customer_id
HAVING 
COUNT(rental_id) < 5

--4. Finding to which store customers visit often and whether they are active

Select 
		case 
			when store_id =1 AND active = 1 THEN 'S1 Active'
			when store_id =1 AND active = 0 THEN 'S1 Inactive'
			when store_id =2 AND active = 1 THEN 'S2 Active'
			when store_id =2 AND active = 0 THEN 'S2 Inactive'
		end AS store_status,
		count(customer_id) as  no_of_customers
From Customer_Data
group by case 
			when store_id =1 AND active = 1 THEN 'S1 Active'
			when store_id =1 AND active = 0 THEN 'S1 Inactive'
			when store_id =2 AND active = 1 THEN 'S2 Active'
			when store_id =2 AND active = 0 THEN 'S2 Inactive'
		end

--Narrowing down the above aggregation

Select 
	store_id,
	COUNT(CASE when active=1 then customer_id else null end) as ACTIVE,
	COUNT(CASE when active=0 then customer_id else null end) as INACTIVE
From
	Customer_Data
Group by store_id

--5. JOIN

--Find what movies the customers watched

SELECT Product_Data.film_title,
		Customer_Data.customer_id
FROM Product_Data
	 JOIN Customer_Data
		ON Customer_Data.transaction_id = Product_Data.transaction_id
		WHERE Customer_Data.customer_id IS NOT NULL