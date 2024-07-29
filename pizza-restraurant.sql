/*
  create at lest 3 tables; resturant
  -transactoin
  -staff
  -menu
  -ingradient
  -...
  write sql queries at least 3 queries
  - with clause
  - subquery
  - aggreate function & Group by
*/

--- create staff Table ---
CREATE TABLE staff (
  staff_id int,
  name text
);

INSERT INTO staff VALUES 
  (1,  'John'),
  (2,  'Somchai'),
  (3,  'Malee'),
  (4,  'Benjamin');

--- create menu Table ---
CREATE TABLE menu (
  menu_id     int,
  menu_name   text,
  calories    int,
  price       real
);

INSERT INTO menu VALUES
  (11,  'Pizza',         500,  300),
  (12,  'Hamburger',     300,  99),
  (13,  'Salad',         200,  129),
  (14,  'French Fries',  250,  59); 

--- create ingradient Table ---

CREATE TABLE ingradient (
  ingradient_id int,
  ingradient_name text,
  cost int
);

INSERT INTO ingradient VALUES
  (21,   'Tomato',   5),
  (22,   'Cheese',   25),
  (23,   'Bacon',    50),
  (24,   'Lettuce',  5),
  (25,   'Onion',    5),
  (26,   'Pickle',   7),
  (27,   'Flour',    10);

-- create menu component Table ---

CREATE TABLE menu_component (
  menu_id int,
  ingradient_id int,
  quantity int
);

INSERT INTO menu_component VALUES
  (11, 21,  2),
  (11, 22,  1),
  (11, 23,  1),
  (11, 27,  1),
  (12, 21,  1),
  (12, 23,  1),
  (12, 24,  1),
  (12, 25,  1),
  (12, 27,  1),
  (13, 21,  1),
  (13, 24,  1),
  (13, 26,  3),
  (14, 21,  3);

--- create transactions Table ---
CREATE TABLE transactions (
  transaction_id int,
  selling_date date,
  staff_id int,
  menu_id int,
  quantity int
);

INSERT INTO transactions VALUES
  (01, '2024-01-20', 1, 11, 11),
  (02, '2024-02-14', 2, 12, 10),
  (03, '2024-03-13', 3, 13, 20),
  (04, '2024-04-12', 4, 14, 12),
  (05, '2024-01-11', 3, 11, 15),
  (06, '2024-02-10', 2, 12, 30),
  (07, '2024-03-02', 1, 13, 15),
  (08, '2024-01-06', 2, 14, 31),
  (09, '2024-02-06', 3, 11, 21),
  (010, '2024-03-05', 4, 12, 22),
  (011, '2024-04-03', 1, 13, 23),
  (012, '2024-01-02', 2, 14, 45),
  (013, '2024-02-01', 3, 11, 100),
  (014, '2024-03-10', 4, 12, 13),
  (015, '2024-04-11', 1, 13, 25),
  (016, '2024-01-12', 2, 14, 30),
  (017, '2024-02-13', 3, 12, 78),
  (018, '2024-03-11', 2, 12, 33),
  (019, '2024-04-21', 4, 13, 15),
  (020, '2024-04-21', 4, 11, 24);

.mode table
.header on
  
--- Review all table ---
SELECT * FROM staff;
SELECT * FROM menu;
SELECT * FROM ingradient;
SELECT * FROM menu_component;
SELECT * FROM transactions;

--- calculate selling quantity by month ---
SELECT 
  STRFTIME('%Y-%m', selling_date)   AS month,
  SUM(quantity)                     AS totalQTY
FROM transactions
GROUP BY month;

--- calculate Total Sales by month ---
SELECT 
  STRFTIME('%Y-%m', t1.selling_date)   AS month,
  SUM(t1.quantity * t2.price)          AS totalSales
FROM transactions    AS t1
JOIN menu            AS t2
  ON t1.menu_id = t2.menu_id
GROUP BY month;

--- Calulate Total cost, Total sales and Total margin by menu ---
WITH 
  cost AS (
  SELECT
    t1.menu_id,
    SUM(t1.quantity*t2.cost)        AS cost  
  FROM menu_component  AS t1 
  JOIN ingradient      AS t2 ON t1.ingradient_id = t2.ingradient_id
  GROUP BY 1
)

SELECT
    t1.menu_id,
    SUM(t1.quantity)                       AS TotalQTY,
    SUM(t1.quantity * t3.price)            AS TotalSales,
    SUM(t1.quantity)* t2.cost              AS TotalCost,
    (SUM(t1.quantity * t3.price)) - (SUM(t1.quantity)* t2.cost)    AS TotalMargin
  FROM transactions           AS t1
  JOIN cost                   AS t2 ON t1.menu_id = t2.menu_id
  JOIN menu                   AS t3 ON t1.menu_id = t3.menu_id
  GROUP BY 1;


--- Calculate Pizza TotalMargin by month ---
WITH 
  cost_of_pizza AS (
  SELECT 
      t1.menu_id,
      SUM(t1.quantity*t2.cost)        AS cost  
  FROM menu_component  AS t1 
  JOIN ingradient      AS t2 ON t1.ingradient_id = t2.ingradient_id
  WHERE t1.menu_id = 11
)
SELECT
    STRFTIME('%Y-%m', t1.selling_date)     AS month,
    SUM(t1.quantity)                       AS TotalQTY,
    SUM(t1.quantity * t3.price)            AS TotalSales,
    SUM(t1.quantity)* t2.cost              AS TotalCost,
    (SUM(t1.quantity * t3.price)) - (SUM(t1.quantity)* t2.cost)    AS TotalMargin
  FROM transactions           AS t1
  JOIN cost_of_pizza          AS t2 ON t1.menu_id = t2.menu_id
  JOIN menu                   AS t3 ON t1.menu_id = t3.menu_id
  WHERE t1.menu_id = 11
  GROUP BY 1;

--- Find the greatest staff of selling pizza ---
SELECT
  staff_id,
  (SELECT SUM(quantity) FROM transactions WHERE menu_id = 11 AND staff.staff_id = staff_id) AS totalQTY
FROM staff
WHERE totalQTY IS NOT NULL
ORDER BY totalQTY DESC
LIMIT 1;
