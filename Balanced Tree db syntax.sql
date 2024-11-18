-- Step 1: Create the Database
CREATE DATABASE balanced_tree;

-- Step 2: Create Tables
CREATE TABLE product_hierarchy (
  id INT,
  parent_id INT,
  level_text VARCHAR(19),
  level_name VARCHAR(8)
);

CREATE TABLE product_prices (
  id INT,
  product_id VARCHAR(6),
  price INT
);

CREATE TABLE product_details (
  product_id VARCHAR(6),
  price INT,
  product_name VARCHAR(32),
  category_id INT,
  segment_id INT,
  style_id INT,
  category_name VARCHAR(6),
  segment_name VARCHAR(6),
  style_name VARCHAR(19)
);

CREATE TABLE sales (
  prod_id VARCHAR(6),
  qty INT,
  price INT,
  discount INT,
  member VARCHAR(1),
  txn_id VARCHAR(6),
  start_txn_time TIMESTAMP
);

-- Step 3: Insert Data into Tables
INSERT INTO product_hierarchy (id, parent_id, level_text, level_name)
VALUES
  (1, NULL, 'Womens', 'Category'),
  (2, NULL, 'Mens', 'Category'),
  (3, 1, 'Jeans', 'Segment'),
  (4, 1, 'Jacket', 'Segment'),
  (5, 2, 'Shirt', 'Segment'),
  (6, 2, 'Socks', 'Segment'),
  (7, 3, 'Navy Oversized', 'Style'),
  (8, 3, 'Black Straight', 'Style'),
  (9, 3, 'Cream Relaxed', 'Style'),
  (10, 4, 'Khaki Suit', 'Style'),
  (11, 4, 'Indigo Rain', 'Style'),
  (12, 4, 'Grey Fashion', 'Style'),
  (13, 5, 'White Tee', 'Style'),
  (14, 5, 'Teal Button Up', 'Style'),
  (15, 5, 'Blue Polo', 'Style'),
  (16, 6, 'Navy Solid', 'Style'),
  (17, 6, 'White Striped', 'Style'),
  (18, 6, 'Pink Fluro Polkadot', 'Style');

INSERT INTO product_prices (id, product_id, price)
VALUES
  (7, 'c4a632', 13),
  (8, 'e83aa3', 32),
  (9, 'e31d39', 10),
  (10, 'd5e9a6', 23),
  (11, '72f5d4', 19),
  (12, '9ec847', 54),
  (13, '5d267b', 40),
  (14, 'c8d436', 10),
  (15, '2a2353', 57),
  (16, 'f084eb', 36),
  (17, 'b9a74d', 17),
  (18, '2feb6b', 29);

INSERT INTO product_details 
  (product_id, price, product_name, category_id, segment_id, style_id, category_name, segment_name, style_name)
VALUES
  ('c4a632', 13, 'Navy Oversized Jeans - Womens', 1, 3, 7, 'Womens', 'Jeans', 'Navy Oversized'),
  ('e83aa3', 32, 'Black Straight Jeans - Womens', 1, 3, 8, 'Womens', 'Jeans', 'Black Straight'),
  ('e31d39', 10, 'Cream Relaxed Jeans - Womens', 1, 3, 9, 'Womens', 'Jeans', 'Cream Relaxed'),
  ('d5e9a6', 23, 'Khaki Suit Jacket - Womens', 1, 4, 10, 'Womens', 'Jacket', 'Khaki Suit'),
  ('72f5d4', 19, 'Indigo Rain Jacket - Womens', 1, 4, 11, 'Womens', 'Jacket', 'Indigo Rain'),
  ('9ec847', 54, 'Grey Fashion Jacket - Womens', 1, 4, 12, 'Womens', 'Jacket', 'Grey Fashion'),
  ('5d267b', 40, 'White Tee Shirt - Mens', 2, 5, 13, 'Mens', 'Shirt', 'White Tee'),
  ('c8d436', 10, 'Teal Button Up Shirt - Mens', 2, 5, 14, 'Mens', 'Shirt', 'Teal Button Up'),
  ('2a2353', 57, 'Blue Polo Shirt - Mens', 2, 5, 15, 'Mens', 'Shirt', 'Blue Polo'),
  ('f084eb', 36, 'Navy Solid Socks - Mens', 2, 6, 16, 'Mens', 'Socks', 'Navy Solid'),
  ('b9a74d', 17, 'White Striped Socks - Mens', 2, 6, 17, 'Mens', 'Socks', 'White Striped'),
  ('2feb6b', 29, 'Pink Fluro Polkadot Socks - Mens', 2, 6, 18, 'Mens', 'Socks', 'Pink Fluro Polkadot');

INSERT INTO sales (prod_id, qty, price, discount, member, txn_id, start_txn_time)
VALUES
  ('c4a632', '4', '13', '17', 't', '54f307', '2021-02-13 01:59:43.296'),
  ('5d267b', '4', '40', '17', 't', '54f307', '2021-02-13 01:59:43.296'),
  ('b9a74d', '4', '17', '17', 't', '54f307', '2021-02-13 01:59:43.296'),
  ('2feb6b', '2', '29', '17', 't', '54f307', '2021-02-13 01:59:43.296'),
  ('c4a632', '5', '13', '21', 't', '26cc98', '2021-01-19 01:39:00.3456'),
  ('e31d39', '2', '10', '21', 't', '26cc98', '2021-01-19 01:39:00.3456'),
  ('72f5d4', '3', '19', '21', 't', '26cc98', '2021-01-19 01:39:00.3456'),
  ('2a2353', '3', '57', '21', 't', '26cc98', '2021-01-19 01:39:00.3456');
  
  -- Step 4: Update member column values to boolean-compatible integers
SET SQL_SAFE_UPDATES = 0;

UPDATE sales
SET member = CASE
    WHEN member = 't' THEN 1
    WHEN member = 'f' THEN 0
    ELSE NULL
END;

SET SQL_SAFE_UPDATES = 1;

-- Step 5: Alter the member column to TINYINT(1)
ALTER TABLE sales
MODIFY COLUMN member TINYINT(1);

-- Step 6: Verify Changes
SELECT member, COUNT(*) AS count
FROM sales
GROUP BY member;
