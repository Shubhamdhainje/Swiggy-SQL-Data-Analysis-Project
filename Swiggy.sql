-- CREATE A DATABASE SWIGGY DATA
CREATE DATABASE swiggy_data;

-- CREATE SWIGGY TABLE
DROP TABLE IF EXISTS swiggy;
CREATE TABLE swiggy(
	State VARCHAR(100),
	city VARCHAR(100),
	order_date DATE,
	restaurant_name VARCHAR(150),
	location VARCHAR(100),
	category VARCHAR(100),
	dish_name VARCHAR(150),
	price NUMERIC(10, 2),
	rating NUMERIC(10, 2),
	rating_count INT
);

SELECT * FROM swiggy;

-- IMPORT THE DATA INTO SWIGGY TABLE
COPY swiggy(state, city, order_date, restaurant_name, location, category, dish_name, price, rating, rating_count)
FROM 'F:\2023_Desktop\SQL_Project\Swiggy\Swiggy_Data.csv'
CSV HEADER;

-- DATA VALIDATION AND CLEANING
-- CHECK NULL VALUE
SELECT
	  SUM(CASE WHEN state IS NULL THEN 1 ELSE 0 END) AS null_state,
	  SUM(CASE WHEN city IS NULL THEN 1 ELSE 0 END) AS null_city,
	  SUM(CASE WHEN order_date IS NULL THEN 1 ELSE 0 END) AS null_order_date,
	  SUM(CASE WHEN restaurant_name IS NULL THEN 1 ELSE 0 END) AS null_restaurant_name,
	  SUM(CASE WHEN location IS NULL THEN 1 ELSE 0 END) AS null_location,
	  SUM(CASE WHEN category IS NULL THEN 1 ELSE 0 END) AS null_cetegory,
	  SUM(CASE WHEN dish_name IS NULL THEN 1 ELSE 0 END) AS null_dish_name,
	  SUM(CASE WHEN price IS NULL THEN 1 ELSE 0 END) AS null_price,
	  SUM(CASE WHEN rating IS NULL THEN 1 ELSE 0 END) AS null_rating,
	  SUM(CASE WHEN rating_count IS NULL THEN 1 ELSE 0 END) AS null_rating_count
FROM swiggy;

-- CHECK BLANK OR EMPTY STRING
SELECT * FROM swiggy
WHERE state = '' OR city = '' OR restaurant_name = '' OR location = '' OR category = '' OR dish_name = '';

-- CHECK DUPLICATE 
SELECT 
	state, city, order_date, restaurant_name, location, category,
	dish_name, price, rating, rating_count, COUNT(*) AS cnt
FROM swiggy
GROUP BY state, city, order_date, restaurant_name, location, category,
		dish_name, price, rating, rating_count
HAVING COUNT(*) > 1;

-- DELETE DUPLICATE
WITH CTE AS(
	SELECT ctid 
	FROM (
		  SELECT ctid, ROW_NUMBER() OVER(PARTITION BY state, city, order_date, restaurant_name, location, category,
										 dish_name, price, rating, rating_count ORDER BY ctid
		 ) AS rn
		  FROM swiggy
	) s
	WHERE rn > 1
)
DELETE FROM swiggy
WHERE ctid IN(SELECT ctid FROM CTE);

-- CREATING SCHEMA
--DIMENSION TABLE
-- DATE TABLE
CREATE TABLE dim_date(
	date_id SERIAL PRIMARY KEY,
	full_date DATE,
	year INT,
	month INT,
	monthname VARCHAR(20),
	quarter INT,
	day INT,
	week INT
);

SELECT * FROM dim_date;

-- CREATE DIM_LOCATION TABLE
DROP TABLE IF EXISTS location;
CREATE TABLE dim_location(
	location_id SERIAL PRIMARY KEY,
	state VARCHAR(100),
	city VARCHAR(100),
	location VARCHAR(200)
);

SELECT * FROM dim_location;

--CREATE DIM_RESTAURANT TABLE 
CREATE TABLE dim_restaurant(
	restaurant_id SERIAL PRIMARY KEY,
	restaurant_name VARCHAR(200)
);

SELECT * FROM dim_restaurant;

-- CREATE DIM_CATEGORY TABLE
CREATE TABLE dim_category(
	category_id SERIAL PRIMARY KEY,
	category VARCHAR(200)
);

SELECT * FROM dim_category;

-- CREATE DIM_DISH TABLE
CREATE TABLE dim_dish(
	dish_id SERIAL PRIMARY KEY,
	dish_name VARCHAR(200)
);

SELECT * FROM dim_dish;

-- CREATE FACT_SWIGGY TABLE
CREATE TABLE fact_swiggy(
	order_id SERIAL PRIMARY KEY,

	date_id INT,
	price NUMERIC(10 ,2),
	rating NUMERIC(10, 2),
	rating_count INT,

	location_id INT,
	restaurant_id INT,
	category_id INT,
	dish_id INT,

	FOREIGN KEY (date_id) REFERENCES dim_date(date_id),
	FOREIGN KEY (location_id) REFERENCES dim_location(location_id),
	FOREIGN KEY (restaurant_id) REFERENCES dim_restaurant(restaurant_id),
	FOREIGN KEY (category_id) REFERENCES dim_category(category_id),
	FOREIGN KEY (dish_id) REFERENCES dim_dish(dish_id)
);

SELECT * FROM fact_swiggy;

-- INSERT DATA INTO DIM_DATE
INSERT INTO dim_date
(full_date, year, month, monthname, quarter, day, week)
SELECT DISTINCT
	order_date, 
	EXTRACT(year FROM order_date),
	EXTRACT(month FROM order_date),
	TO_CHAR(order_date, 'month'),
	EXTRACT(quarter FROM order_date),
	EXTRACT(day FROM order_date),
	EXTRACT(week FROM order_date)
FROM swiggy
WHERE order_date IS NOT NULL;

SELECT * FROM dim_date;

-- INSERT DATE INTO DIM_LOCATION
INSERT INTO dim_location
(state, city, location)
SELECT DISTINCT
		state,
		city,
		location
FROM swiggy;

SELECT * FROM dim_location;

-- INSERT DATA INTO A DIM_RESTAURANT TABLE
INSERT INTO dim_restaurant
(restaurant_name)
SELECT DISTINCT
	restaurant_name
FROM swiggy;

SELECT * FROM dim_restaurant;

-- INSERT DATA INTO DIM_CATEGORY TABLE
INSERT INTO dim_category
(category)
SELECT DISTINCT
 	category
FROM swiggy;

SELECT * FROM dim_category;

-- INSERT DATA INTO DIM_DISH TABLE
INSERT INTO dim_dish
(dish_name)
SELECT DISTINCT 
	dish_name
FROM swiggy;

SELECT * FROM dim_dish;

-- INSERT DATA INTO FACT_SWIGGY TABLE
INSERT INTO fact_swiggy
(	date_id, 
	price, 
	rating,
	rating_count,
	location_id,
	restaurant_id,
	category_id,
	dish_id
)
SELECT 
	dd.date_id,
	s.price,
	s.rating,
	s.rating_count,
	dl.location_id,
	dr.restaurant_id,
	dc.category_id,
	dsh.dish_id
FROM swiggy s

JOIN dim_date dd
ON dd.full_date = s.order_date

JOIN dim_location dl
ON dl.state = s.state
AND dl.city = s.city
AND dl.location = s.location

JOIN dim_restaurant dr
ON dr.restaurant_name = s.restaurant_name

JOIN dim_category dc
ON dc.category = s.category

JOIN dim_dish dsh
ON dsh.dish_name = s.dish_name;

SELECT * FROM fact_swiggy;

SELECT * FROM fact_swiggy f
JOIN dim_date d 
ON d.date_id = f.date_id
JOIN dim_location l
ON l.location_id = f.location_id
JOIN dim_restaurant r
ON r.restaurant_id = f.restaurant_id
JOIN dim_category c
ON c.category_id = f.category_id
JOIN dim_dish di
ON di.dish_id = f.dish_id;

--KPI
-- 1) TOTAL ORDERS
SELECT * FROM fact_swiggy;

SELECT COUNT(*) AS total_orders
FROM fact_swiggy;

-- 2) TOTAL REVENUE (INR MILLION)
SELECT SUM(price) AS total_revenue
FROM fact_swiggy;

SELECT 
	TO_CHAR(SUM(price) / 1000000, 'FM90.00') || ' INR MILLION' 
	AS total_revenue
FROM fact_swiggy;

-- 3) AVERAGE DISH PRICE
SELECT AVG(price) AS avg_dish_price
FROM fact_swiggy;

SELECT 
	TO_CHAR(AVG(price) , 'FM990.00') || ' INR ' 
	AS avg_dish_price
FROM fact_swiggy;

-- 4) AVERAGE RATING
SELECT AVG(rating) AS avg_rating
FROM fact_swiggy;

SELECT 
	TO_CHAR(AVG(rating) , 'FM90.00')  
	AS avg_rating
FROM fact_swiggy;

-- Deep-Dive Business Analysis
-- DATE BASE ANALYSIS
-- 1) MONTHLY ORDER TRENDS 
SELECT 
	d.year, d.month, d.monthname,
	COUNT(*) AS monthly_order
FROM fact_swiggy f
JOIN dim_date d
ON d.date_id = f.date_id
GROUP BY d.year, d.month, d.monthname
ORDER BY COUNT(*) DESC;

-- 2) TOTAL MONTHLY REVENUE 	
SELECT 
	d.year, d.month, d.monthname,
	SUM(price) AS total_revenue
FROM fact_swiggy f
JOIN dim_date d
ON d.date_id = f.date_id
GROUP BY d.year, d.month, d.monthname
ORDER BY SUM(price) DESC;

SELECT 
	d.year, d.month, d.monthname,
	TO_CHAR(SUM(price) / 1000000, 'FM90.00') || ' INR MILLION' 
	AS total_revenue
FROM fact_swiggy f
JOIN dim_date d
ON d.date_id = f.date_id
GROUP BY d.year, d.month, d.monthname
ORDER BY SUM(price) DESC;

-- 3) QUARTERLY ORDER TRENDS  
SELECT 
	d.year, d.quarter,
	COUNT(*) AS quarter_order_trends
FROM fact_swiggy f
JOIN dim_date d
ON d.date_id = f.date_id
GROUP BY d.year, d.quarter
ORDER BY quarter_order_trends DESC;

-- 4) YEAR WISE GROWTH
SELECT d.year,
	COUNT(*) AS yearly_growth
FROM fact_swiggy f
JOIN dim_date d
ON d.date_id = f.date_id
GROUP BY d.year
ORDER BY yearly_growth DESC;

--5) ORDERS BY DAY OF WEEK ( MON - SUN)
SELECT 
	TO_CHAR(d.full_date, 'Day') AS day_name,
	COUNT(*) AS total_orders
FROM fact_swiggy f
JOIN dim_date d
ON d.date_id = f.date_id
GROUP BY day_name 
ORDER BY total_orders DESC;

-- LOCATION BASED ANALYSIS
--  1) TOP 10 CITITES BY ORDER VOLUMES
SELECT l.city,
	COUNT(*) AS total_orders
FROM fact_swiggy f
JOIN dim_location l
ON l.location_id = f.location_id
GROUP BY l.city
ORDER BY total_orders DESC
LIMIT 10;

-- 2) REVENUE CONTRIBUTION BY STATES
SELECT 
	l.state,
	SUM(price) AS total_revenue
FROM fact_swiggy f
JOIN dim_location l
ON l.location_id = f.location_id
GROUP BY l.state
ORDER BY total_revenue DESC;

SELECT 
	l.state,
	TO_CHAR(SUM(price) / 1000000 ,'FM999.00') || ' INR MILLION' 
	AS total_revenue
FROM fact_swiggy f
JOIN dim_location l
ON l.location_id = f.location_id
GROUP BY l.state
ORDER BY total_revenue DESC;

-- FOOD PERFORMANCE BASED ANALYSIS
-- 1) TOP 10 RESTAURANT BY ORDERS
SELECT 
	r.restaurant_name,
	COUNT(*) AS total_orders
FROM fact_swiggy f
JOIN dim_restaurant r
ON r.restaurant_id = f.restaurant_id
GROUP BY r.restaurant_name
ORDER BY total_orders DESC
LIMIT 10;

-- 2) TOP CATEGORIES BY ORDER VOLUMES
SELECT 
	c.category,
	COUNT(*) AS total_orders
FROM fact_swiggy f
JOIN dim_category c
ON c.category_id = f.category_id 
GROUP BY c.category
ORDER BY total_orders DESC;

-- 3) MOST ORDERED DISHES
SELECT 
	dis.dish_name ,
	COUNT(*) AS total_orders
FROM fact_swiggy f
JOIN dim_dish dis
ON dis.dish_id = f.dish_id 
GROUP BY dis.dish_name
ORDER BY total_orders DESC;

-- 4) CUISINE PERFORMANCE (ORDERS _ AVG RATING)
SELECT 
	c.category,
	COUNT(*) AS total_orders,
	AVG(rating) AS avg_rating
FROM fact_swiggy f
JOIN dim_category c
ON c.category_id = f.category_id
GROUP BY c.category
ORDER BY total_orders DESC;

SELECT 
	c.category,
	COUNT(*) AS total_orders,
	TO_CHAR(AVG(rating), 'FM99.00') AS avg_rating
FROM fact_swiggy f
JOIN dim_category c
ON c.category_id = f.category_id
GROUP BY c.category
ORDER BY total_orders DESC;

-- CUSTOMER SPENDING INSIGHTS
-- 1) TOTAL ORDER BY PRICE RANGES
SELECT
	CASE WHEN price < 100 THEN 'Under 100'
		 WHEN price BETWEEN 100 AND 199 THEN '100 - 199'
		 WHEN price BETWEEN 200 AND 299 THEN '200 - 299'
		 WHEN price BETWEEN 300 AND 499 THEN '300 - 499'
		 ELSE '500+'
	END AS price_range,
	COUNT(*) AS total_orders
FROM fact_swiggy 
GROUP BY 
	CASE WHEN price < 100 THEN 'Under 100'
		 WHEN price BETWEEN 100 AND 199 THEN '100 - 199'
		 WHEN price BETWEEN 200 AND 299 THEN '200 - 299'
		 WHEN price BETWEEN 300 AND 499 THEN '300 - 499'
		 ELSE '500+'
	END 
ORDER BY total_orders DESC;	

-- RATING ANALYSIS
-- 1) RATING COUNT DISTRIBUTION (1 - 5)
SELECT 
	rating,
	COUNT(*) AS rating_count
FROM fact_swiggy 
GROUP BY rating
ORDER BY rating DESC;
