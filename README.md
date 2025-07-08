# product-sales-dashboard
# 📊 Product-Level Sales Performance Dashboard

This project showcases a dynamic Power BI dashboard designed to analyze product-level sales performance, marketing efficiency, and category-level trends. It demonstrates my ability to extract insights from raw data using SQL and visualize them effectively for business decision-making.

---

## 🎯 Objective

To analyze sales performance across product categories and individual SKUs, identify high-performing products, and evaluate the effectiveness of marketing spend and discount strategies.

---

## 🛠 Tools & Technologies

- **SQL**: Data extraction, transformation, validation, Data cleaning and exploratory analysis  
- **Power BI**: Interactive dashboard design and DAX calculations  

---

## 📌 Key Features

- **KPI Overview**: Total revenue, units sold, average units per product, and marketing spend  
- **Category-Level Analysis**: Compare revenue vs units sold across product categories  
- **Product-Level Deep Dive**: Top 5 products by revenue and average revenue per unit  
- **Time-Based Trends**: Monthly and daily sales patterns  

---

## 💡 Sample Insights

- 🏆 Electronics generated the highest revenue despite being second in units sold, indicating a higher price per unit.  
- 🪑 Furniture sold the most units but ranked second in revenue, suggesting lower average value per item.  
- 📉 Clothing showed a unique seasonal dip in February and November, unlike other categories.  
- 💸 Products with high marketing spend but low ROI were identified for optimization.

---

## 📷 Dashboard Preview

![image](https://github.com/user-attachments/assets/1673fd7c-d370-4cd7-979b-925e52e0ba72)


---

## 🔗 Live Dashboard (Optional)

If hosted online:  
[👉 View Interactive Dashboard](https://mailkmuttacth-my.sharepoint.com/:u:/g/personal/lapat_chai_kmutt_ac_th/Efmw_YtFCo5HmOKNqtNCNzEBkkPOJ0Ay8xPVv1j1y_nYTw?e=ak3dsW)

---

## 📁 Files Included

- `![Screenshot 2025-07-08 203959](https://github.com/user-attachments/assets/32a2c94c-f4b9-42d7-9dea-fa1108b15f49)
` – Dashboard preview  
# 📦 Retail Sales Data Preparation & Enrichment


-- Create base table
```sql
CREATE TABLE retail_sales (
    store_id             VARCHAR(15),
    product_id           VARCHAR(15),
    date                 DATE,
    units_sold           INT,
    sales_revenue        FLOAT,
    discount_percentage  INT,
    marketing_spend      INT,
    store_location       VARCHAR(70),
    product_category     VARCHAR(20),
    date_of_week         VARCHAR(20),
    holiday_effect       VARCHAR(20)
);
```
-- Add numeric day of week (0 = Sunday)
```sql
ALTER TABLE retail_sales ADD COLUMN date_num_week INT;
UPDATE retail_sales SET date_num_week = EXTRACT(DOW FROM date);
```
-- Add month name (e.g. Jan, Feb)
```sql
ALTER TABLE retail_sales ADD COLUMN date_name_m VARCHAR(20);
UPDATE retail_sales SET date_name_m = TO_CHAR(date, 'FMMon');
```
-- Add numeric month
```sql
ALTER TABLE retail_sales ADD COLUMN date_num_m INT;
UPDATE retail_sales SET date_num_m = EXTRACT(MONTH FROM date);
```
-- Add year (generated column)
```sql
ALTER TABLE retail_sales ADD COLUMN date_num_y INT GENERATED ALWAYS AS (EXTRACT(YEAR FROM date)) STORED;
```
-- Rename column for clarity
```sql
ALTER TABLE retail_sales RENAME COLUMN day_of_the_week TO date_of_week;
```

# 🔍 Data Quality Checks


-- Check for any nulls
```sql
SELECT * FROM retail_sales WHERE * IS NULL;
```
-- Check for duplicates based on key dimensions
```sql
WITH duplicate_check AS (
    SELECT *,
           ROW_NUMBER() OVER (
               PARTITION BY product_id, date, store_location, product_category, date_of_week
               ORDER BY date
           ) AS row_num
    FROM retail_sales
)
SELECT COUNT(*) FROM duplicate_check WHERE row_num >= 2;
```
-- Check for nulls using JSON (alternative method)
```sql
SELECT *
FROM retail_sales
WHERE EXISTS (
    SELECT 1
    FROM json_each_text(row_to_json(retail_sales)) AS kv
    WHERE kv.value IS NULL
);
```

# 🧮 Enrichment: Net Revenue & Marketing Efficiency


-- Create enriched table with calculated columns
```sql
CREATE TABLE retail_sales_enriched AS
WITH enriched_sales AS (
    SELECT *,
           CAST(sales_revenue * (1 - discount_percentage / 100.0) AS DECIMAL(10,2)) AS net_revenue,
           CAST(
               CASE 
                   WHEN marketing_spend > 0 THEN sales_revenue / marketing_spend
                   ELSE 0
               END AS DECIMAL(10,2)
           ) AS marketing_efficiency
    FROM retail_sales
)
SELECT * FROM enriched_sales;
```
-- Update day name format
```sql
UPDATE retail_sales_enriched SET date_of_week = TO_CHAR(date, 'FMDy');
```
# 📊 Exploratory Queries & KPIs

-- Total Sales Revenue
```sql
SELECT SUM(sales_revenue) AS total_sale FROM retail_sales;
```
-- Total Units Sold
```sql
SELECT SUM(units_sold) AS total_units_sold FROM retail_sales;
```
-- Total Marketing Spend
```sql
SELECT SUM(marketing_spend) AS total_marketing_spend FROM retail_sales;
```
-- Sales by Product, Year, Month
```sql
SELECT 
    product_id,
    date_num_y AS year,
    date_num_m AS month,
    CAST(SUM(sales_revenue) AS DECIMAL(10,2)) AS total_sale
FROM retail_sales
GROUP BY 1, 2, 3
ORDER BY 1, 2, 3;
```
-- Units Sold by Product, Year, Month
```sql
SELECT 
    product_id,
    date_num_y AS year,
    date_num_m AS month,
    CAST(SUM(units_sold) AS DECIMAL(10,2)) AS total_unit_sale
FROM retail_sales
GROUP BY 1, 2, 3
ORDER BY 1, 2, 3;
```
-- Units Sold by Product per Month
```sql
SELECT 
    date_num_y AS year,
    date_num_m AS month,
    product_id,
    SUM(units_sold) AS total_sold
FROM retail_sales_enriched
GROUP BY 1, 2, 3
ORDER BY 1, 2;
```
` – SQL scripts used for data extraction  

---

## 🙋 About Me

I'm Lapat, a data enthusiast passionate about turning raw data into actionable insights.  
This project reflects my interest in business intelligence, storytelling, and continuous improvement.

📫 Connect with me on [LinkedIn/Lapat-Cprd](https://www.linkedin.com/in/lapat-cprd?lipi=urn%3Ali%3Apage%3Ad_flagship3_profile_view_base_contact_details%3B2PX2cEjaTeyhWZwljZF7fQ%3D%3D)  
📂 Explore more projects at [github.com/Lapat-Cprd](https://github.com/Lapat-Cprd)
