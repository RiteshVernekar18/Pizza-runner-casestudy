

  SELECT * FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'CUSTOMER_ORDERS'

  [dbo].[runner_orders]


SELECT * FROM customer_orders
SELECT * FROM pizza_names
SELECT * FROM pizza_recipes
SELECT * FROM pizza_toppings
SELECT * FROM runner_orders
SELECT * FROM runners

 ------DATA CLEANING PART-------
/* 
   first we need to create a table before doing any cleaning
    then using update function we will clean the unneccesary values
*/
------------------------------first we will clean customer_order table---------------------------------

 CREATE TABLE CUSTOMER_ORDERS_COPY
 ("ORDER_ID" INT,"CUSTOMER_ID" INT,"PIZZA_ID" INT,"EXCLUSIONS" VARCHAR(20),"EXTRAS" VARCHAR(20),"ORDER_TIME" DATETIME)

 SELECT * FROM  CUSTOMER_ORDERS_COPY
 SELECT ORDER_ID,CUSTOMER_ID,PIZZA_ID,EXCLUSIONS,EXTRAS,ORDER_TIME FROM customer_orders

 UPDATE CUSTOMER_ORDERS_COPY
 SET
    EXCLUSIONS = CASE
	  WHEN EXCLUSIONS = ' ' THEN NULL
	  WHEN EXCLUSIONS = '' THEN NULL
	  WHEN EXCLUSIONS = 'null' THEN NULL
	ELSE EXCLUSIONS
	END;

UPDATE CUSTOMER_ORDERS_COPY
SET 
   EXTRAS = CASE
     WHEN EXTRAS = '' THEN NULL
	 WHEN EXTRAS = ' ' THEN NULL
	 WHEN EXTRAS = 'null' THEN NULL
	 WHEN EXTRAS = NULL THEN NULL
	ELSE EXTRAS
	END;

-----------------------------Runner_ordes table cleaning making this constent--------------------------------
/*
   then using update function we will clean this table as well
    */
 
CREATE TABLE RUNNER_ORDERS_COPY1
("ORDER_ID" INT,
 "RUNNER_ID" INT,
 "PICKUP_TIME" VARCHAR(20),
 "DISTANCE" VARCHAR(20),
 "DURATION" VARCHAR(20),
 "CANCELLATION" VARCHAR(50)
 )

 SELECT * FROM RUNNER_ORDERS_COPY1
 INSERT INTO RUNNER_ORDERS_COPY1
 SELECT 
  ORDER_ID,
  RUNNER_ID,
  PICKUP_TIME,
  DISTANCE,
  DURATION,
  CANCELLATION
FROM runner_orders

UPDATE RUNNER_ORDERS_COPY1
SET 
   DISTANCE = CASE
    WHEN DISTANCE = 'null' THEN NULL
	ELSE DISTANCE
	END

UPDATE RUNNER_ORDERS_COPY1
SET
   PICKUP_TIME = CASE
    WHEN PICKUP_TIME = 'null' THEN NULL
    ELSE PICKUP_TIME
	END

UPDATE RUNNER_ORDERS_COPY1
SET
   DURATION = CASE
    WHEN DURATION = 'null' THEN NULL
	ELSE DURATION
	END

UPDATE RUNNER_ORDERS_COPY1
SET
   CANCELLATION = CASE
    WHEN CANCELLATION = '' THEN NULL
	WHEN CANCELLATION = ' ' THEN NULL
	WHEN CANCELLATION = 'null' THEN NULL
	ELSE CANCELLATION
	END

UPDATE RUNNER_ORDERS_COPY1
SET 
   DISTANCE = REPLACE(DISTANCE,'km','')
   WHERE DISTANCE LIKE '%km'

------------------------------altering distance column to decimal-------------------------------------

ALTER TABLE RUNNER_ORDERS_COPY1
ALTER COLUMN DISTANCE DECIMAL(3,1)

----------------------------------this part converting all 'minutes' to 'mins'-----------------------------------

UPDATE RUNNER_ORDERS_COPY1
SET
   DURATION = (SELECT
    CASE 
	    WHEN DURATION LIKE '%' THEN CONCAT(SUBSTRING(DURATION,1,2),' ','mins')
		WHEN DURATION LIKE '% minutes' THEN CONCAT(SUBSTRING(DURATION,1,2),' ','mins')
		WHEN DURATION LIKE '%minute' THEN CONCAT(SUBSTRING(DURATION,1,2),' ','mins')
		ELSE DURATION
		END
		)

----------------------------------Let's solve the questions here--------------------------------------

--How many pizzas were ordered?
SELECT 
      COUNT(ORDER_ID) AS PIZZA_ORDERED
FROM 
     CUSTOMER_ORDERS_COPY

--How many unique customer orders were made?
SELECT 
      COUNT(DISTINCT ORDER_ID) AS UNIQUE_CUST
FROM 
    CUSTOMER_ORDERS_COPY

--How many successful orders were delivered by each runner?
SELECT 
      RUNNER_ID,
	  COUNT(ORDER_ID) AS SUCCESFULL_DELIVERY
FROM RUNNER_ORDERS_COPY1
WHERE DURATION IS NOT NULL
GROUP BY RUNNER_ID

--How many of each type of pizza was delivered?
SELECT 
      P.pizza_name,
	  COUNT(C.ORDER_ID) AS ORDER_DELIVERED
FROM CUSTOMER_ORDERS_COPY C
JOIN RUNNER_ORDERS_COPY1 R ON C.ORDER_ID = R.ORDER_ID
JOIN pizza_names P ON C.PIZZA_ID = P.pizza_id
GROUP BY P.pizza_name

--How many Vegetarian and Meatlovers were ordered by each customer?
SELECT 
      C.CUSTOMER_ID,
	  P.pizza_name,
	  COUNT(C.PIZZA_ID) AS PIZZA_DELIVERED
FROM CUSTOMER_ORDERS_COPY C
JOIN pizza_names P ON C.PIZZA_ID = P.pizza_id
GROUP BY C.CUSTOMER_ID,P.pizza_name
ORDER BY C.CUSTOMER_ID

--What was the maximum number of pizzas delivered in a single order?
SELECT  TOP 1
      CUSTOMER_ID,
      ORDER_ID,
	  COUNT(ORDER_ID) AS PIZZA_DELIVERED
FROM CUSTOMER_ORDERS_COPY
GROUP BY ORDER_ID,CUSTOMER_ID
ORDER BY COUNT(ORDER_ID) DESC

--For each customer, how many delivered pizzas had at least 1 change and how many had no changes?
SELECT 
      C.CUSTOMER_ID,
	  COUNT(R.ORDER_ID) AS PIZZA_DELIVERED,
	  SUM(CASE
	          WHEN C.EXCLUSIONS IS NOT NULL OR C.EXTRAS IS NOT NULL THEN 1 
			  ELSE 0
			  END) AS HAVE_1_CHANGE,
      SUM(CASE
	          WHEN C.EXCLUSIONS IS NULL AND C.EXTRAS IS NULL THEN 1
			  ELSE 0
			  END) AS HAVE_0_CHANGE
FROM CUSTOMER_ORDERS_COPY C
JOIN RUNNER_ORDERS_COPY1 R ON C.ORDER_ID = R.ORDER_ID
GROUP BY C.CUSTOMER_ID
ORDER BY C.CUSTOMER_ID

--How many pizzas were delivered that had both exclusions and extras?
SELECT
      C.CUSTOMER_ID,
	  COUNT(R.ORDER_ID) AS PIZZA_DELIVERED,
	  SUM(CASE
	          WHEN C.EXCLUSIONS IS NOT NULL 
			  AND C.EXTRAS IS NOT NULL THEN 1 
			  ELSE 0
			  END) AS HAVE_CHANGES
FROM CUSTOMER_ORDERS_COPY C
JOIN RUNNER_ORDERS_COPY1 R ON C.ORDER_ID = R.ORDER_ID
GROUP BY C.CUSTOMER_ID

--What was the total volume of pizzas ordered for each hour of the day?
SELECT 
      DATEPART(HOUR, ORDER_TIME) AS 'HOUR',
	  COUNT(ORDER_ID) AS NO_OF_ORDERS
FROM CUSTOMER_ORDERS_COPY
GROUP BY DATEPART(HOUR,  ORDER_TIME)
ORDER BY DATEPART(HOUR,  ORDER_TIME)

--What was the volume of orders for each day of the week?
SELECT 
     DATENAME(DW,ORDER_TIME) AS DAY_OF_WEEK,
	 COUNT(ORDER_ID) AS NO_OF_ORDERS
FROM CUSTOMER_ORDERS_COPY
GROUP BY DATENAME(DW,ORDER_TIME)


 


			  

   
    
   
