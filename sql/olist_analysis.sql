

--  Create project schema

CREATE SCHEMA IF NOT EXISTS olist;

--  CUSTOMERS TABLE

CREATE TABLE IF NOT EXISTS olist.olist_customers_dataset (
    customer_id VARCHAR(50),
    customer_unique_id VARCHAR(50),
    customer_zip_code_prefix INTEGER,
    customer_city VARCHAR(100),
    customer_state CHAR(2)
);


--  GEOLOCATION TABLE

CREATE TABLE IF NOT EXISTS olist.olist_geolocation_dataset (
    geolocation_zip_code_prefix INTEGER,
    geolocation_lat NUMERIC(10,8),
    geolocation_lng NUMERIC(11,8),
    geolocation_city VARCHAR(100),
    geolocation_state CHAR(2)
);


--  ORDER ITEMS TABLE
 
CREATE TABLE IF NOT EXISTS olist.olist_order_items_dataset (
    order_id VARCHAR(50),
    order_item_id INTEGER,
    product_id VARCHAR(50),
    seller_id VARCHAR(50),
    shipping_limit_date TIMESTAMP,
    price NUMERIC(12,2),
    freight_value NUMERIC(12,2)
);


--  ORDER PAYMENTS TABLE

CREATE TABLE IF NOT EXISTS olist.olist_order_payments_dataset (
    order_id VARCHAR(50),
    payment_sequential INTEGER,
    payment_type VARCHAR(50),
    payment_installments INTEGER,
    payment_value NUMERIC(12,2)
);


--  ORDER REVIEWS TABLE

CREATE TABLE IF NOT EXISTS olist.olist_order_reviews_dataset (
    review_id VARCHAR(50),
    order_id VARCHAR(50),
    review_score INTEGER,
    review_comment_title TEXT,
    review_comment_message TEXT,
    review_creation_date TIMESTAMP,
    review_answer_timestamp TIMESTAMP
);


--  ORDERS TABLE

CREATE TABLE IF NOT EXISTS olist.olist_orders_dataset (
    order_id VARCHAR(50),
    customer_id VARCHAR(50),
    order_status VARCHAR(30),
    order_purchase_timestamp TIMESTAMP,
    order_approved_at TIMESTAMP,
    order_delivered_carrier_date TIMESTAMP,
    order_delivered_customer_date TIMESTAMP,
    order_estimated_delivery_date TIMESTAMP
);


--  PRODUCTS TABLE

CREATE TABLE IF NOT EXISTS olist.olist_products_dataset (
    product_id VARCHAR(50),
    product_category_name VARCHAR(100),
    product_name_length INTEGER,
    product_description_length INTEGER,
    product_photos_qty INTEGER,
    product_weight_g INTEGER,
    product_length_cm INTEGER,
    product_height_cm INTEGER,
    product_width_cm INTEGER
);


--  SELLERS TABLE

CREATE TABLE IF NOT EXISTS olist.olist_sellers_dataset (
    seller_id VARCHAR(50),
    seller_zip_code_prefix INTEGER,
    seller_city VARCHAR(100),
    seller_state CHAR(2)
);


--  PRODUCT CATEGORY TRANSLATION TABLE

CREATE TABLE IF NOT EXISTS olist.product_category_name_translation (
    product_category_name VARCHAR(100),
    product_category_name_english VARCHAR(100)
);


-- STAGE 2: DATA EXPLORATION AND QUALITY CHECKS



-- VERIFY ALL 9 TABLES EXIST

SELECT
    table_schema,
    table_name
FROM information_schema.tables
WHERE table_schema = 'olist'
ORDER BY table_name;


-- CHECK TOTAL ROWS IN ALL 9 TABLES

SELECT 'customers' AS table_name, COUNT(*) AS total_rows
FROM olist.olist_customers_dataset

UNION ALL

SELECT 'geolocation', COUNT(*)
FROM olist.olist_geolocation_dataset

UNION ALL

SELECT 'order_items', COUNT(*)
FROM olist.olist_order_items_dataset

UNION ALL

SELECT 'order_payments', COUNT(*)
FROM olist.olist_order_payments_dataset

UNION ALL

SELECT 'order_reviews', COUNT(*)
FROM olist.olist_order_reviews_dataset

UNION ALL

SELECT 'orders', COUNT(*)
FROM olist.olist_orders_dataset

UNION ALL

SELECT 'products', COUNT(*)
FROM olist.olist_products_dataset

UNION ALL

SELECT 'sellers', COUNT(*)
FROM olist.olist_sellers_dataset

UNION ALL

SELECT 'category_translation', COUNT(*)
FROM olist.product_category_name_translation;


-- INSPECT SAMPLE RECORDS

SELECT *
FROM olist.olist_orders_dataset
LIMIT 10;

SELECT *
FROM olist.olist_order_items_dataset
LIMIT 10;


-- MISSING VALUE ANALYSIS - ORDERS

SELECT
    COUNT(*) AS total_rows,

    COUNT(*) FILTER (
        WHERE order_id IS NULL
    ) AS missing_order_id,

    COUNT(*) FILTER (
        WHERE customer_id IS NULL
    ) AS missing_customer_id,

    COUNT(*) FILTER (
        WHERE order_status IS NULL
    ) AS missing_order_status,

    COUNT(*) FILTER (
        WHERE order_purchase_timestamp IS NULL
    ) AS missing_purchase_date,

    COUNT(*) FILTER (
        WHERE order_approved_at IS NULL
    ) AS missing_approval_date,

    COUNT(*) FILTER (
        WHERE order_delivered_customer_date IS NULL
    ) AS missing_delivery_date,

    COUNT(*) FILTER (
        WHERE order_estimated_delivery_date IS NULL
    ) AS missing_estimated_date

FROM olist.olist_orders_dataset;


-- MISSING VALUE ANALYSIS - ORDER ITEMS

SELECT
    COUNT(*) AS total_rows,

    COUNT(*) FILTER (
        WHERE order_id IS NULL
    ) AS missing_order_id,

    COUNT(*) FILTER (
        WHERE product_id IS NULL
    ) AS missing_product_id,

    COUNT(*) FILTER (
        WHERE seller_id IS NULL
    ) AS missing_seller_id,

    COUNT(*) FILTER (
        WHERE price IS NULL
    ) AS missing_price,

    COUNT(*) FILTER (
        WHERE freight_value IS NULL
    ) AS missing_freight

FROM olist.olist_order_items_dataset;


-- CHECK DUPLICATE ORDERS

SELECT
    order_id,
    COUNT(*) AS occurrences
FROM olist.olist_orders_dataset
GROUP BY order_id
HAVING COUNT(*) > 1
ORDER BY occurrences DESC;


--  CHECK DUPLICATE ORDER ITEMS

SELECT
    order_id,
    order_item_id,
    COUNT(*) AS occurrences
FROM olist.olist_order_items_dataset
GROUP BY order_id, order_item_id
HAVING COUNT(*) > 1;


-- CHECK ORDER STATUSES

SELECT
    order_status,
    COUNT(*) AS total_orders
FROM olist.olist_orders_dataset
GROUP BY order_status
ORDER BY total_orders DESC;


-- CHECK INVALID PRICES

SELECT *
FROM olist.olist_order_items_dataset
WHERE price < 0
   OR freight_value < 0;


-- CHECK ZERO VALUE RECORDS

SELECT *
FROM olist.olist_order_items_dataset
WHERE price = 0
   OR freight_value = 0;


-- CHECK UNUSUAL ITEM NUMBERS

SELECT *
FROM olist.olist_order_items_dataset
WHERE order_item_id <= 0;


-- CHECK DATE CONSISTENCY

-- Approval before purchase

SELECT *
FROM olist.olist_orders_dataset
WHERE order_approved_at < order_purchase_timestamp;


-- Carrier date before purchase

SELECT *
FROM olist.olist_orders_dataset
WHERE order_delivered_carrier_date
      < order_purchase_timestamp;


-- Delivery before purchase

SELECT *
FROM olist.olist_orders_dataset
WHERE order_delivered_customer_date
      < order_purchase_timestamp;


-- Delivery before carrier date

SELECT *
FROM olist.olist_orders_dataset
WHERE order_delivered_customer_date
      < order_delivered_carrier_date;


-- Delivered orders without delivery date

SELECT *
FROM olist.olist_orders_dataset
WHERE order_status = 'delivered'
AND order_delivered_customer_date IS NULL;


-- CHECK TABLE RELATIONSHIPS

-- Order items without matching orders

SELECT
    oi.order_id
FROM olist.olist_order_items_dataset oi
LEFT JOIN olist.olist_orders_dataset o
    ON oi.order_id = o.order_id
WHERE o.order_id IS NULL;


-- Orders without matching order items

SELECT
    o.order_id
FROM olist.olist_orders_dataset o
LEFT JOIN olist.olist_order_items_dataset oi
    ON o.order_id = oi.order_id
WHERE oi.order_id IS NULL;


-- CALCULATE AVERAGE DELIVERY TIME

SELECT
    ROUND(
        AVG(
            EXTRACT(
                EPOCH FROM (
                    order_delivered_customer_date
                    - order_purchase_timestamp
                )
            ) / 86400
        )::NUMERIC,
        2
    ) AS avg_delivery_days

FROM olist.olist_orders_dataset

WHERE order_status = 'delivered'
AND order_delivered_customer_date IS NOT NULL;


-- ON-TIME VS LATE DELIVERIES

SELECT
    CASE
        WHEN order_delivered_customer_date
             <= order_estimated_delivery_date
        THEN 'On Time or Early'
        ELSE 'Late'
    END AS delivery_performance,

    COUNT(*) AS total_orders

FROM olist.olist_orders_dataset

WHERE order_status = 'delivered'
AND order_delivered_customer_date IS NOT NULL
AND order_estimated_delivery_date IS NOT NULL

GROUP BY 1;


--  ON-TIME DELIVERY PERCENTAGE


SELECT
    COUNT(*) AS total_delivered_orders,

    COUNT(*) FILTER (
        WHERE order_delivered_customer_date
              <= order_estimated_delivery_date
    ) AS on_time_orders,

    COUNT(*) FILTER (
        WHERE order_delivered_customer_date
              > order_estimated_delivery_date
    ) AS late_orders,

    ROUND(
        100.0 * COUNT(*) FILTER (
            WHERE order_delivered_customer_date
                  <= order_estimated_delivery_date
        ) / NULLIF(COUNT(*), 0),
        2
    ) AS on_time_percentage

FROM olist.olist_orders_dataset

WHERE order_status = 'delivered'
AND order_delivered_customer_date IS NOT NULL
AND order_estimated_delivery_date IS NOT NULL;



-- STAGE 3: BUSINESS ANALYSIS



--  ITEMS PER ORDER

SELECT
    order_id,
    COUNT(*) AS total_items
FROM olist.olist_order_items_dataset
GROUP BY order_id
ORDER BY total_items DESC
LIMIT 20;


--  TOTAL PRODUCT REVENUE

SELECT
    ROUND(SUM(price), 2) AS total_product_revenue
FROM olist.olist_order_items_dataset;


--  PRODUCT REVENUE + FREIGHT

SELECT
    ROUND(SUM(price), 2) AS product_revenue,
    ROUND(SUM(freight_value), 2) AS total_freight,
    ROUND(SUM(price + freight_value), 2) AS combined_value
FROM olist.olist_order_items_dataset;


-- TOTAL UNIQUE ORDERS

SELECT
    COUNT(DISTINCT order_id) AS total_orders
FROM olist.olist_orders_dataset;


-- AVERAGE ORDER VALUE

SELECT
    ROUND(
        SUM(price) / NULLIF(COUNT(DISTINCT order_id), 0),
        2
    ) AS average_order_value
FROM olist.olist_order_items_dataset;


-- ORDER STATUS DISTRIBUTION

SELECT
    order_status,
    COUNT(*) AS total_orders,
    ROUND(
        100.0 * COUNT(*) / SUM(COUNT(*)) OVER (),
        2
    ) AS percentage
FROM olist.olist_orders_dataset
GROUP BY order_status
ORDER BY total_orders DESC;


-- MONTHLY PRODUCT REVENUE

SELECT
    DATE_TRUNC(
        'month',
        o.order_purchase_timestamp
    )::DATE AS purchase_month,

    ROUND(SUM(oi.price), 2) AS monthly_revenue

FROM olist.olist_orders_dataset o

JOIN olist.olist_order_items_dataset oi
    ON o.order_id = oi.order_id

GROUP BY 1
ORDER BY 1;


--  TOP 5 REVENUE MONTHS

SELECT
    DATE_TRUNC(
        'month',
        o.order_purchase_timestamp
    )::DATE AS purchase_month,

    ROUND(SUM(oi.price), 2) AS monthly_revenue

FROM olist.olist_orders_dataset o

JOIN olist.olist_order_items_dataset oi
    ON o.order_id = oi.order_id

GROUP BY 1
ORDER BY monthly_revenue DESC
LIMIT 5;


-- REVENUE BY ORDER STATUS

SELECT
    o.order_status,
    COUNT(DISTINCT o.order_id) AS total_orders,
    ROUND(SUM(oi.price), 2) AS product_value

FROM olist.olist_orders_dataset o

LEFT JOIN olist.olist_order_items_dataset oi
    ON o.order_id = oi.order_id

GROUP BY o.order_status
ORDER BY product_value DESC NULLS LAST;


--  TOP 10 HIGHEST-VALUE ORDERS

SELECT
    order_id,
    ROUND(SUM(price), 2) AS order_value,
    COUNT(*) AS total_items

FROM olist.olist_order_items_dataset

GROUP BY order_id

ORDER BY order_value DESC

LIMIT 10;







--  RANK PRODUCTS BY REVENUE


WITH product_revenue AS (
    SELECT
        product_id,
        SUM(price) AS revenue
    FROM olist.olist_order_items_dataset
    GROUP BY product_id
)

SELECT
    product_id,
    ROUND(revenue, 2) AS revenue,
    RANK() OVER (
        ORDER BY revenue DESC
    ) AS revenue_rank
FROM product_revenue
ORDER BY revenue_rank
LIMIT 20;



--  RANK VS DENSE_RANK VS ROW_NUMBER


SELECT
    product_id,
    SUM(price) AS revenue,

    RANK() OVER (
        ORDER BY SUM(price) DESC
    ) AS rank_value,

    DENSE_RANK() OVER (
        ORDER BY SUM(price) DESC
    ) AS dense_rank_value,

    ROW_NUMBER() OVER (
        ORDER BY SUM(price) DESC, product_id
    ) AS row_number_value

FROM olist.olist_order_items_dataset
GROUP BY product_id
ORDER BY revenue DESC
LIMIT 20;



--  CUSTOMER FIRST AND LATEST PURCHASE


SELECT
    c.customer_unique_id,
    MIN(o.order_purchase_timestamp) AS first_purchase,
    MAX(o.order_purchase_timestamp) AS latest_purchase,
    COUNT(DISTINCT o.order_id) AS total_orders

FROM olist.olist_customers_dataset c

JOIN olist.olist_orders_dataset o
    ON c.customer_id = o.customer_id

GROUP BY c.customer_unique_id
ORDER BY total_orders DESC;



--  DAYS BETWEEN FIRST AND LATEST PURCHASE


WITH customer_history AS (
    SELECT
        c.customer_unique_id,
        MIN(o.order_purchase_timestamp) AS first_purchase,
        MAX(o.order_purchase_timestamp) AS latest_purchase,
        COUNT(DISTINCT o.order_id) AS total_orders

    FROM olist.olist_customers_dataset c

    JOIN olist.olist_orders_dataset o
        ON c.customer_id = o.customer_id

    GROUP BY c.customer_unique_id
)

SELECT
    customer_unique_id,
    total_orders,

    ROUND(
        (
            EXTRACT(
                EPOCH FROM (latest_purchase - first_purchase)
            ) / 86400
        )::NUMERIC,
        2
    ) AS days_between_purchases

FROM customer_history
WHERE total_orders > 1
ORDER BY days_between_purchases DESC;



--  CUSTOMER FREQUENCY SEGMENTATION


WITH customer_orders AS (
    SELECT
        c.customer_unique_id,
        COUNT(DISTINCT o.order_id) AS total_orders

    FROM olist.olist_customers_dataset c

    JOIN olist.olist_orders_dataset o
        ON c.customer_id = o.customer_id

    GROUP BY c.customer_unique_id
),

customer_segments AS (
    SELECT
        customer_unique_id,
        total_orders,

        CASE
            WHEN total_orders = 1
                THEN 'One-time Customer'
            WHEN total_orders BETWEEN 2 AND 3
                THEN 'Repeat Customer'
            ELSE 'Frequent Customer'
        END AS customer_segment

    FROM customer_orders
)

SELECT
    customer_segment,
    COUNT(*) AS total_customers

FROM customer_segments
GROUP BY customer_segment
ORDER BY total_customers DESC;



--  TOP 20 CUSTOMERS BY REVENUE


WITH customer_revenue AS (
    SELECT
        c.customer_unique_id,
        SUM(oi.price) AS total_revenue

    FROM olist.olist_customers_dataset c

    JOIN olist.olist_orders_dataset o
        ON c.customer_id = o.customer_id

    JOIN olist.olist_order_items_dataset oi
        ON o.order_id = oi.order_id

    GROUP BY c.customer_unique_id
)

SELECT
    customer_unique_id,
    ROUND(total_revenue, 2) AS total_revenue,

    RANK() OVER (
        ORDER BY total_revenue DESC
    ) AS customer_revenue_rank

FROM customer_revenue
ORDER BY customer_revenue_rank
LIMIT 20;



--  DELIVERY DELAYS BY MONTH


SELECT
    DATE_TRUNC(
        'month',
        order_purchase_timestamp
    )::DATE AS purchase_month,

    COUNT(*) AS delivered_orders,

    ROUND(
        AVG(
            EXTRACT(
                EPOCH FROM (
                    order_delivered_customer_date
                    - order_estimated_delivery_date
                )
            ) / 86400
        )::NUMERIC,
        2
    ) AS average_days_vs_estimate

FROM olist.olist_orders_dataset

WHERE order_status = 'delivered'
AND order_delivered_customer_date IS NOT NULL
AND order_estimated_delivery_date IS NOT NULL

GROUP BY 1
ORDER BY 1;



--  REVIEW SCORE DISTRIBUTION


SELECT
    review_score,
    COUNT(*) AS total_reviews,

    ROUND(
        100.0 * COUNT(*) / SUM(COUNT(*)) OVER (),
        2
    ) AS review_percentage

FROM olist.olist_order_reviews_dataset

GROUP BY review_score
ORDER BY review_score;



--  DELIVERY PERFORMANCE VS REVIEW SCORES


SELECT
    CASE
        WHEN o.order_delivered_customer_date
             > o.order_estimated_delivery_date
        THEN 'Late'
        ELSE 'On Time or Early'
    END AS delivery_category,

    COUNT(*) AS total_reviews,

    ROUND(
        AVG(r.review_score)::NUMERIC,
        2
    ) AS average_review_score

FROM olist.olist_orders_dataset o

JOIN olist.olist_order_reviews_dataset r
    ON o.order_id = r.order_id

WHERE o.order_status = 'delivered'
AND o.order_delivered_customer_date IS NOT NULL
AND o.order_estimated_delivery_date IS NOT NULL

GROUP BY 1;



--  PAYMENT METHOD ANALYSIS


SELECT
    payment_type,
    COUNT(*) AS payment_records,
    COUNT(DISTINCT order_id) AS unique_orders,

    ROUND(SUM(payment_value), 2) AS total_payment_value,

    ROUND(AVG(payment_value), 2) AS average_payment_value

FROM olist.olist_order_payments_dataset

GROUP BY payment_type
ORDER BY total_payment_value DESC;



--  REVENUE CONTRIBUTION OF TOP 10% PRODUCTS


WITH product_revenue AS (
    SELECT
        product_id,
        SUM(price) AS revenue

    FROM olist.olist_order_items_dataset
    GROUP BY product_id
),

ranked_products AS (
    SELECT
        product_id,
        revenue,

        NTILE(10) OVER (
            ORDER BY revenue DESC
        ) AS revenue_decile

    FROM product_revenue
)

SELECT
    ROUND(
        100.0 * SUM(
            CASE
                WHEN revenue_decile = 1 THEN revenue
                ELSE 0
            END
        ) / NULLIF(SUM(revenue), 0),
        2
    ) AS top_10_percent_revenue_contribution

FROM ranked_products;



--  CATEGORY-WISE AVERAGE SELLING PRICE


SELECT
    p.product_category_name,
    COUNT(*) AS total_items_sold,

    ROUND(
        AVG(oi.price),
        2
    ) AS average_selling_price,

    ROUND(
        SUM(oi.price),
        2
    ) AS total_product_revenue

FROM olist.olist_order_items_dataset oi

JOIN olist.olist_products_dataset p
    ON oi.product_id = p.product_id

GROUP BY p.product_category_name
ORDER BY average_selling_price DESC;


-- DELIVERY DELAYS BY CUSTOMER STATE

SELECT
    c.customer_state,

    COUNT(*) AS delivered_orders,

    ROUND(
        AVG(
            EXTRACT(
                EPOCH FROM (
                    o.order_delivered_customer_date
                    - o.order_estimated_delivery_date
                )
            ) / 86400
        )::NUMERIC,
        2
    ) AS average_days_vs_estimate

FROM olist.olist_orders_dataset o

JOIN olist.olist_customers_dataset c
    ON o.customer_id = c.customer_id

WHERE o.order_status = 'delivered'
AND o.order_delivered_customer_date IS NOT NULL
AND o.order_estimated_delivery_date IS NOT NULL

GROUP BY c.customer_state
ORDER BY average_days_vs_estimate DESC;

