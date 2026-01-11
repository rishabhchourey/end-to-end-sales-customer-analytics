create database local_business_analytics;
use local_business_analytics;

create table customers(
customer_id varchar(10) primary key,
customer_name varchar(100),
age int,
gender varchar(10),
city varchar(50),
join_date date
);

create table products(
product_id varchar(10) primary key,
product_name varchar(100),
category varchar(50),
price decimal(10,2)
);

CREATE TABLE orders (
    order_id VARCHAR(10) PRIMARY KEY,
    customer_id VARCHAR(10),
    product_id VARCHAR(10),
    order_date DATE,
    quantity INT,
    FOREIGN KEY (customer_id) REFERENCES customers(customer_id),
    FOREIGN KEY (product_id) REFERENCES products(product_id),
    price int
);

CREATE TABLE payments (
    payment_id VARCHAR(10) PRIMARY KEY,
    order_id VARCHAR(10),
    payment_mode VARCHAR(20),
    payment_status VARCHAR(20),
    FOREIGN KEY (order_id) REFERENCES orders(order_id)
);

CREATE TABLE feedback (
    order_id VARCHAR(10),
    rating INT,
    review VARCHAR(255),
    FOREIGN KEY (order_id) REFERENCES orders(order_id)
);



-- Total Revenue & Order Performance

SELECT 
    SUM(quantity * price) AS total_revenue,
    COUNT(DISTINCT order_id) AS total_orders
FROM orders;

-- Monthly Revenue

SELECT 
    DATE_FORMAT(order_date, '%Y-%m') AS month,
    SUM(quantity * price) AS monthly_revenue
FROM orders
GROUP BY month
ORDER BY month;

-- Customer Contribution to revenue

SELECT 
    c.customer_name,
    c.city,
    SUM(o.quantity * o.price) AS customer_revenue
FROM orders o
JOIN customers c 
    ON o.customer_id = c.customer_id
GROUP BY c.customer_name, c.city
ORDER BY customer_revenue DESC
LIMIT 10;

-- Product Type Performance 

SELECT 
    p.Food,
    p.Fitness,
    p.Electronics,
    p.Services,
    SUM(o.quantity * o.price) AS revenue
FROM orders o
JOIN products p 
    ON o.product_id = p.product_id
GROUP BY p.Food, p.Fitness, p.Electronics, p.Services
ORDER BY revenue DESC;

-- Order Quantity Analysis

SELECT 
    SUM(quantity) AS total_units_sold,
    AVG(quantity) AS avg_order_quantity
FROM orders;

-- Payment Success & failure Rate

SELECT 
    payment_status,
    COUNT(*) AS total_payments
FROM payments
GROUP BY payment_status;

-- Revenue Lost Due to Failed Payments

SELECT 
    SUM(o.quantity * o.price) AS revenue_lost
FROM orders o
JOIN payments p 
    ON o.order_id = p.order_id
WHERE p.payment_status = 'Failed';

-- Customer Feedback Analysis

SELECT 
    AVG(rating) AS avg_rating,
    COUNT(review) AS total_reviews
FROM feedback;

-- Rating vs Revenue Impact

SELECT 
    f.rating,
    SUM(o.quantity * o.price) AS revenue
FROM orders o
JOIN feedback f 
    ON o.order_id = f.order_id
GROUP BY f.rating
ORDER BY f.rating DESC;

select * from products,orders;
select * from customers;
select * from orders;




CREATE VIEW business_master_view AS
SELECT
    o.order_id,
    o.order_date,
    c.customer_id,
    c.customer_name,
    c.age,
    c.city,
    o.product_id,
    o.quantity,
    o.price,
    (o.quantity * o.price) AS total_amount,
    pay.payment_mode,
    pay.payment_status,
    f.rating,
    f.review
FROM orders o
JOIN customers c 
    ON o.customer_id = c.customer_id
LEFT JOIN payments pay 
    ON o.order_id = pay.order_id
LEFT JOIN feedback f 
    ON o.order_id = f.order_id;