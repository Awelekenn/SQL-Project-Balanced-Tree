/* PROJECT DESCRIPTION
Balanced Tree Clothing Company prides themselves on providing an optimised range of clothing and lifestyle wear for the modern adventurer!
Danny has asked to assist the team’s merchandising teams analyse their sales performance and generate a basic financial report to share with the wider business. */

-- What was the total quantity sold for all products?
SELECT 
  SUM(qty) as total_quantity_sold
FROM sales;
-- What is the total generated revenue for all products before discounts?
SELECT 
  SUM(price * qty) AS total_revenue_before_discounts
from sales;
-- What was the total discount amount for all products?
SELECT 
  ROUND(SUM(price * qty * (discount/100)),2) as total_discount_amount
FROM SALES;

-- What is the total quantity, revenue and discount for each segment?
SELECT 
  p.segment_name, 
  SUM(s.qty) as total_quantity,
  SUM(s.price * s.qty) as total_revenue, 
  ROUND(SUM(s.price * s.qty* (s.discount/100)),2) as total_discount
FROM sales as s
JOIN product_details as p
ON s.prod_id = p.product_id
GROUP BY p.segment_name;

-- What is the top selling product for each segment?

WITH CTE AS(
SELECT 
  p.product_name, 
  p.segment_name, 
  SUM(s.price * s.qty * (1 - s.discount/100)) as total_revenue
FROM sales as s
JOIN product_details as p
ON s.prod_id = p.product_id
GROUP BY p.product_name, p.segment_name
ORDER BY total_revenue DESC
),
ranked_products AS(
SELECT 
  product_name, 
  segment_name, 
  total_revenue,
  RANK() OVER (PARTITION BY segment_name ORDER BY total_revenue DESC) as rank_segment
FROM CTE
)
SELECT 
  product_name, 
  segment_name, 
  total_revenue
FROM ranked_products
WHERE rank_segment = 1;

-- What is the total quantity, revenue and discount for each category?
SELECT 
  p.category_name, 
  SUM(s.qty) as total_quantity,
  SUM(s.price * s.qty) as total_revenue, 
  ROUND(SUM(s.price * s.qty* (s.discount/100)),2) as total_discount
FROM sales as s
JOIN product_details as p
ON s.prod_id = p.product_id
GROUP BY p.category_name;

-- What is the top selling product for each category?
WITH CTE AS(
SELECT 
  p.product_name, p.category_name,
  SUM(s.price * s.qty * (1 - s.discount/100)) as total_revenue
FROM Sales as s
JOIN product_details as p
ON s.prod_id = p.product_id
GROUP BY p.product_name, p.category_name
),
ranked_products AS (
SELECT 
  product_name, 
  category_name, 
  total_revenue,
  RANK() OVER (PARTITION BY category_name ORDER BY total_revenue DESC) as rank_category
FROM CTE
)
SELECT 
  product_name, 
  category_name, 
  ROUND(total_revenue,2) AS revenue
FROM ranked_products
WHERE rank_category = 1;

-- What is the percentage split of revenue by product for each segment?

WITH revenue_by_product AS (
SELECT 
  p.product_name,
  p.segment_name,
  ROUND(SUM(s.qty * s.price * (1 - (s.discount/100))),2) as product_revenue
FROM Sales as s
JOIN product_details as p 
ON p.product_id = s.prod_id
GROUP BY p.product_name,p.segment_name
),
segment_revenue as (
SELECT 
  segment_name, 
  SUM(product_revenue) as segment_revenue
FROM revenue_by_product
GROUP BY segment_name
)
SELECT 
  o.segment_name,
  r.product_name,
  r.product_revenue,
  ROUND(((r.product_revenue/o.segment_revenue*100)),0) as percentage_split
FROM segment_revenue as o
JOIN revenue_by_product as r
ON o.segment_name = r.segment_name;

-- What is the percentage split of revenue by segment for each category?
-- segment revenue/category revenue * 100 
WITH rev_by_segment AS (
SELECT 
  p.segment_name,
  p.category_name,
  SUM(s.qty * s.price * (1 - (s.discount/100))) as segment_revenue
FROM Sales as s
JOIN product_details as p
ON p.product_id = s.prod_id
GROUP BY p.segment_name, p.category_name
),
rev_by_cat as(
SELECT 
  category_name, 
  SUM(segment_revenue) as category_revenue
FROM rev_by_segment
GROUP BY category_name
)
SELECT 
  sr.segment_name, 
  cr.category_name, 
  sr.segment_revenue as total_revenue,
  ROUND(((segment_revenue/category_revenue)*100),0) as percentage_split
FROM rev_by_segment as sr
JOIN rev_by_cat as cr
ON sr.category_name = cr.category_name; 

-- What is the percentage split of total revenue by category?
-- category rev/total rev *100 

WITH rev_by_cat AS (
SELECT 
  p.category_name,
  SUM(s.qty * s.price * (1 - (s.discount/100))) as category_revenue
FROM sales as s
JOIN product_details as p
GROUP BY p.category_name
),
total_rev AS (
SELECT 
  SUM(category_revenue) AS total_revenue 
FROM rev_by_cat
)
SELECT 
 cr.category_name,
 ((cr.category_revenue/tr.total_revenue)*100) AS percentage_split
FROM rev_by_cat AS cr
JOIN total_rev AS tr;

-- What is the total transaction “penetration” for each product? (hint: penetration = number of transactions where at least 1 quantity of a product was purchased divided by total number of transactions)

WITH trans_total AS (
SELECT 
 COUNT(prod_id) as total_no_of_transactions
FROM SALES
),
Trans_penetration AS (
-- number of transactions where at least 1 quantity of a product was purchased
SELECT 
  p.product_name,
  s.prod_id,
  COUNT(s.prod_id) AS no_of_penetration
FROM Sales as s
JOIN Product_details as p
ON p.product_id = s.prod_id
GROUP BY p.product_name,s.prod_id
)
SELECT 
  tp.prod_id, 
  tp.product_name, 
  tp.no_of_penetration,
  (tp.no_of_penetration/t.total_no_of_transactions)*100 as penetration_percent
FROM trans_total as t
JOIN Trans_penetration as tp
ORDER BY penetration_percent DESC;

-- What is the most common combination of at least 1 quantity of any 3 products in a 1 single transaction?
WITH transaction_products AS (
    -- Grouping products by transaction
    SELECT 
        s.txn_id, 
        GROUP_CONCAT(p.product_name ORDER BY p.product_name) AS product_combination
    FROM Sales as s
    JOIN Product_details as p
    ON s.prod_id = p.product_id
    GROUP BY txn_id
    HAVING COUNT(prod_id) = 3  -- Transactions with exactly 3 products
),
combination_count AS (
    -- Counting occurrences of each combination
    SELECT 
        product_combination, 
        COUNT(*) AS occurrence
    FROM transaction_products
    GROUP BY product_combination
)
-- Selecting the most common combination
SELECT 
    product_combination, 
    occurrence
FROM combination_count
ORDER BY occurrence DESC
LIMIT 1;
