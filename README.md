# Swiggy-SQL-Data-Analysis-Project
🍔 Swiggy SQL Data Analysis Project (PostgreSQL)
📌 Project Overview
This project is a SQL-based data analysis case study developed using PostgreSQL.
The objective is to clean, validate, model, and analyze Swiggy food delivery data 
in order to answer predefined business questions related to orders, revenue, ratings, 
locations, and food performance.
All transformations and analysis are performed using SQL.
___________________________________________________________________________________________
🧠 Business Problem Statement
The raw Swiggy dataset contains food delivery records across multiple states, 
cities, restaurants, categories, and dishes.
Before meaningful analysis can be performed, the data must be validated, 
cleaned, and structured.
This project focuses on improving data quality, building an analytical data
model, and extracting business insights using SQL.
___________________________________________________________________________________________
🗄️ Tools & Technology
•	Database: PostgreSQL
•	Tool: pgAdmin 4
•	Language: SQL
___________________________________________________________________________________________
📂 Source Table
•	swiggy_data
Raw table containing food delivery records including:
o	State
o	City
o	Order_Date
o	Restaurant_Name
o	Location
o	Category
o	Dish_Name
o	Price_INR
o	Rating
o	Rating_Count
___________________________________________________________________________________________
🧹 Data Cleaning & Validation
Data quality checks are performed on the raw swiggy_data table before modeling.
1️⃣ Null Value Check
Identify missing values in the following business-critical columns:
•	State
•	City
•	Order_Date
•	Restaurant_Name
•	Location
•	Category
•	Dish_Name
•	Price_INR
•	Rating
•	Rating_Count
__________________________________________________________________________________________
2️⃣ Blank / Empty String Check
Detect columns containing blank or empty string values that may lead to inaccurate analysis.
__________________________________________________________________________________________
3️⃣ Duplicate Detection
Identify duplicate records by grouping on all business-critical columns to ensure data 
uniqueness.
___________________________________________________________________________________________
4️⃣ Duplicate Removal
Use ROW_NUMBER() to:
•	Retain one clean record per unique order
•	Remove surplus duplicate rows
•	Ensure a single, reliable version of each record
___________________________________________________________________________________________
⭐ Dimensional Modelling (Star Schema)
To support efficient analysis and reporting, the cleaned data is transformed into a Star
Schema.
Dimensional modeling:
•	Separates descriptive attributes into dimension tables
•	Stores measurable values in a central fact table
•	Reduces redundancy and improves query performance
•	Enables accurate aggregation and analytics
____________________________________________________________________________________________
📊 Data Model
Dimension Tables
•	dim_date
o	Year
o	Month
o	Quarter
o	Week
•	dim_location
o	State
o	City
o	Location
•	dim_restaurant
o	Restaurant_Name
•	dim_category
o	Cuisine / Category
•	dim_dish
o	Dish_Name
Each dimension table is populated using distinct values from the cleaned source data.
____________________________________________________________________________________________
Fact Table
•	fact_swiggy_orders
o	Price_INR
o	Rating
o	Rating_Count
o	Foreign keys referencing all dimension tables
The fact table is created from the cleaned swiggy_data with all dimension keys resolved.
____________________________________________________________________________________________
📊 Business Analysis Performed
1️⃣ Key Performance Indicators (KPIs)
•	Total orders
•	Total revenue (INR Million)
•	Average dish price
•	Average rating
____________________________________________________________________________________________
2️⃣ Date-Based Analysis
•	Monthly order trends
•	Total monthly revenue
•	Quarterly order trends
•	Year-wise growth
•	Orders by day of the week (Monday–Sunday)
____________________________________________________________________________________________
3️⃣ Location-Based Analysis
•	Top 10 cities by order volume
•	Revenue contribution by state
____________________________________________________________________________________________
4️⃣ Food Performance-Based Analysis
•	Top 10 restaurants by order volume
•	Top categories by order volume
•	Most ordered dishes
•	Cuisine performance based on:
o	Total orders
o	Average rating
____________________________________________________________________________________________
5️⃣ Customer Spending Insights
•	Total orders by price ranges
____________________________________________________________________________________________
6️⃣ Rating Analysis
•	Rating count distribution (ratings from 1 to 5)
____________________________________________________________________________________________
🛠️ SQL Concepts Used
•	Data validation & cleansing
•	Aggregations (SUM, COUNT, AVG)
•	Window functions (ROW_NUMBER)
•	Joins
•	CTEs
•	Date functions
•	Grouping & filtering
____________________________________________________________________________________________
📁 Project Files
•	Swiggy.sql – SQL scripts for cleaning, modeling, and analysis
•	Business Requirements.docx – Business problem definitions
•	README.md – Project documentation
____________________________________________________________________________________________
✅ Conclusion
This project demonstrates a complete SQL analytics workflow — from raw data cleaning and 
validation to dimensional modeling and business analysis. It highlights the practical use 
of PostgreSQL for building a clean, scalable, and analysis-ready data model.
____________________________________________________________________________________________
