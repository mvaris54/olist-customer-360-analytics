CREATE DATABASE IF NOT EXISTS olist_customer_360;
use olist_customer_360;

-- Step 2 SQL: Verify the imported table
USE olist_customer_360;

-- Monthly sales, orders, customers aur growth
SELECT 
    DATE_FORMAT(order_purchase_timestamp, '%Y-%m') AS order_month,
    ROUND(SUM(payment_value), 2) AS revenue,
    COUNT(DISTINCT order_id) AS orders,
    COUNT(DISTINCT customer_unique_id) AS customers
FROM transactions_cleaned
WHERE payment_value IS NOT NULL
GROUP BY DATE_FORMAT(order_purchase_timestamp, '%Y-%m')
ORDER BY order_month;

-- Monthly revenue aur Month-over-Month growth
WITH monthly AS (
    SELECT 
        DATE_FORMAT(order_purchase_timestamp, '%Y-%m') AS order_month,
        SUM(payment_value) AS revenue
    FROM transactions_cleaned
    WHERE payment_value IS NOT NULL
    GROUP BY DATE_FORMAT(order_purchase_timestamp, '%Y-%m')
)

SELECT 
    order_month,
    ROUND(revenue, 2) AS revenue,
    ROUND(LAG(revenue) OVER (ORDER BY order_month), 2) AS prev_month,
    ROUND(
        (revenue - LAG(revenue) OVER (ORDER BY order_month))
        / LAG(revenue) OVER (ORDER BY order_month) * 100, 
        2
    ) AS mom_growth_pct
FROM monthly
ORDER BY order_month;

-- Revenue concentration: Pareto analysis
WITH customer_revenue AS (
    SELECT 
        customer_unique_id,
        ROUND(SUM(payment_value), 2) AS revenue
    FROM transactions_cleaned
    WHERE customer_unique_id IS NOT NULL
      AND payment_value IS NOT NULL
    GROUP BY customer_unique_id
),

ranked AS (
    SELECT 
        customer_unique_id,
        revenue,
        ROW_NUMBER() OVER (ORDER BY revenue DESC) AS rn,
        COUNT(*) OVER () AS total_customers,
        SUM(revenue) OVER (ORDER BY revenue DESC) AS cumulative_revenue,
        (SELECT SUM(revenue) FROM customer_revenue) AS grand_total
    FROM customer_revenue
)

SELECT 
    -- Top 10% customers ka revenue share
    ROUND(
        (SELECT SUM(revenue) FROM ranked WHERE rn <= total_customers * 0.10)
        / MAX(grand_total) * 100, 
        2
    ) AS top_10_share,
    
    -- Top 20% customers ka revenue share
    ROUND(
        (SELECT SUM(revenue) FROM ranked WHERE rn <= total_customers * 0.20)
        / MAX(grand_total) * 100, 
        2
    ) AS top_20_share,
    
    -- Kitne customers chahiye 80% revenue ke liye
    (SELECT MIN(rn) FROM ranked WHERE cumulative_revenue / grand_total >= 0.80) 
        AS customers_for_80,
    
    -- Woh kitne percent hain
    ROUND(
        (SELECT MIN(rn) FROM ranked WHERE cumulative_revenue / grand_total >= 0.80)
        / MAX(total_customers) * 100, 
        2
    ) AS pct_for_80
FROM ranked;

-- RFM metrics per customer
SELECT 
    customer_unique_id,
    DATEDIFF(
        (SELECT DATE_ADD(MAX(order_purchase_timestamp), INTERVAL 1 DAY)
         FROM transactions_cleaned),
        MAX(order_purchase_timestamp)
    ) AS recency,
    COUNT(DISTINCT order_id) AS frequency,
    ROUND(SUM(payment_value), 2) AS monetary
FROM transactions_cleaned
WHERE customer_unique_id IS NOT NULL
  AND payment_value IS NOT NULL
GROUP BY customer_unique_id
LIMIT 10;

-- 
WITH rfm_base AS (
    SELECT 
        customer_unique_id,
        DATEDIFF(
            (SELECT DATE_ADD(MAX(order_purchase_timestamp), INTERVAL 1 DAY)
             FROM transactions_cleaned),
            MAX(order_purchase_timestamp)
        ) AS recency,
        COUNT(DISTINCT order_id) AS frequency,
        ROUND(SUM(payment_value), 2) AS monetary
    FROM transactions_cleaned
    WHERE customer_unique_id IS NOT NULL
      AND payment_value IS NOT NULL
    GROUP BY customer_unique_id
)

SELECT 
    COUNT(*) AS total_customers,
    ROUND(AVG(recency), 2) AS avg_recency,
    ROUND(AVG(frequency), 2) AS avg_frequency,
    ROUND(AVG(monetary), 2) AS avg_monetary,
    MIN(recency) AS min_recency,
    MAX(recency) AS max_recency
FROM rfm_base;

-- RFM Scoring (1-4 scale)
WITH rfm_base AS (
    SELECT 
        customer_unique_id,
        DATEDIFF(
            (SELECT DATE_ADD(MAX(order_purchase_timestamp), INTERVAL 1 DAY)
             FROM transactions_cleaned),
            MAX(order_purchase_timestamp)
        ) AS recency,
        COUNT(DISTINCT order_id) AS frequency,
        ROUND(SUM(payment_value), 2) AS monetary
    FROM transactions_cleaned
    WHERE customer_unique_id IS NOT NULL
      AND payment_value IS NOT NULL
    GROUP BY customer_unique_id
),

scored AS (
    SELECT 
        customer_unique_id,
        recency,
        frequency,
        monetary,
        -- Recency: kam din = accha = score 4
        (5 - NTILE(4) OVER (ORDER BY recency ASC)) AS r_score,
        -- Frequency: zyada orders = accha = score 4
        NTILE(4) OVER (ORDER BY frequency ASC) AS f_score,
        -- Monetary: zyada revenue = accha = score 4
        NTILE(4) OVER (ORDER BY monetary ASC) AS m_score
    FROM rfm_base
)

SELECT * FROM scored
LIMIT 10;


-- Har score mein kitne customers
WITH rfm_base AS (
    SELECT 
        customer_unique_id,
        DATEDIFF(
            (SELECT DATE_ADD(MAX(order_purchase_timestamp), INTERVAL 1 DAY)
             FROM transactions_cleaned),
            MAX(order_purchase_timestamp)
        ) AS recency,
        COUNT(DISTINCT order_id) AS frequency,
        ROUND(SUM(payment_value), 2) AS monetary
    FROM transactions_cleaned
    WHERE customer_unique_id IS NOT NULL
      AND payment_value IS NOT NULL
    GROUP BY customer_unique_id
),
scored AS (
    SELECT 
        (5 - NTILE(4) OVER (ORDER BY recency ASC)) AS r_score,
        NTILE(4) OVER (ORDER BY frequency ASC) AS f_score,
        NTILE(4) OVER (ORDER BY monetary ASC) AS m_score
    FROM rfm_base
)

SELECT 
    r_score,
    COUNT(*) AS cnt
FROM scored
GROUP BY r_score
ORDER BY r_score;


-- Customer Segmentation 
WITH rfm_base AS (
    SELECT 
        customer_unique_id,
        DATEDIFF(
            (SELECT DATE_ADD(MAX(order_purchase_timestamp), INTERVAL 1 DAY)
             FROM transactions_cleaned),
            MAX(order_purchase_timestamp)
        ) AS recency,
        COUNT(DISTINCT order_id) AS frequency,
        ROUND(SUM(payment_value), 2) AS monetary
    FROM transactions_cleaned
    WHERE customer_unique_id IS NOT NULL
      AND payment_value IS NOT NULL
    GROUP BY customer_unique_id
),

ranked AS (
    SELECT 
        customer_unique_id,
        recency,
        frequency,
        monetary,
        -- Row numbers to break ties
        ROW_NUMBER() OVER (ORDER BY recency ASC, customer_unique_id ASC) AS r_rank,
        ROW_NUMBER() OVER (ORDER BY frequency ASC, customer_unique_id ASC) AS f_rank,
        ROW_NUMBER() OVER (ORDER BY monetary ASC, customer_unique_id ASC) AS m_rank
    FROM rfm_base
),

scored AS (
    SELECT 
        customer_unique_id,
        recency,
        frequency,
        monetary,
        (5 - NTILE(4) OVER (ORDER BY r_rank ASC)) AS r_score,
        NTILE(4) OVER (ORDER BY f_rank ASC) AS f_score,
        NTILE(4) OVER (ORDER BY m_rank ASC) AS m_score
    FROM ranked
),

segments AS (
    SELECT 
        customer_unique_id,
        monetary,
        CASE 
            WHEN r_score = 4 AND f_score >= 3 AND m_score >= 3 THEN 'Champions'
            WHEN r_score >= 3 AND f_score >= 2 THEN 'Loyal Customers'
            WHEN r_score <= 2 AND f_score >= 3 AND m_score >= 3 THEN 'Cant Lose'
            WHEN r_score <= 2 AND f_score >= 2 THEN 'At-Risk'
            WHEN r_score <= 2 AND f_score <= 2 AND m_score <= 2 THEN 'Hibernating'
            ELSE 'Regular'
        END AS segment
    FROM scored
)

SELECT 
    segment,
    COUNT(*) AS customer_count,
    ROUND(SUM(monetary), 2) AS total_revenue,
    ROUND(AVG(monetary), 2) AS avg_revenue
FROM segments
GROUP BY segment
ORDER BY customer_count DESC;


WITH order_level AS (
    SELECT order_id, customer_unique_id, order_purchase_timestamp, payment_value
    FROM (
        SELECT 
            order_id,
            customer_unique_id,
            order_purchase_timestamp,
            payment_value,
            ROW_NUMBER() OVER (
                PARTITION BY order_id 
                ORDER BY order_purchase_timestamp DESC
            ) AS rn
        FROM transactions_cleaned
        WHERE customer_unique_id IS NOT NULL
          AND payment_value IS NOT NULL
    ) t
    WHERE rn = 1
),

rfm_base AS (
    SELECT 
        customer_unique_id,
        DATEDIFF(
            (SELECT DATE_ADD(MAX(order_purchase_timestamp), INTERVAL 1 DAY)
             FROM order_level),
            MAX(order_purchase_timestamp)
        ) AS recency,
        ROUND(SUM(payment_value), 2) AS monetary
    FROM order_level
    GROUP BY customer_unique_id
)

SELECT 
    COUNT(*) AS total_customers,
    SUM(CASE WHEN recency > 180 THEN 1 ELSE 0 END) AS churned_customers,
    ROUND(SUM(CASE WHEN recency > 180 THEN 1 ELSE 0 END) / COUNT(*) * 100, 2) AS churn_rate_pct,
    ROUND(SUM(CASE WHEN recency > 180 THEN monetary ELSE 0 END), 2) AS revenue_at_risk,
    ROUND(
        SUM(CASE WHEN recency > 180 THEN monetary ELSE 0 END) / SUM(monetary) * 100, 
        2
    ) AS revenue_at_risk_pct
FROM rfm_base;


-- Repeat Purchase Analysis
WITH order_level AS (
    SELECT order_id, customer_unique_id
    FROM (
        SELECT 
            order_id,
            customer_unique_id,
            ROW_NUMBER() OVER (
                PARTITION BY order_id 
                ORDER BY order_purchase_timestamp DESC
            ) AS rn
        FROM transactions_cleaned
        WHERE customer_unique_id IS NOT NULL
    ) t
    WHERE rn = 1
),

customer_orders AS (
    SELECT 
        customer_unique_id,
        COUNT(DISTINCT order_id) AS order_count
    FROM order_level
    GROUP BY customer_unique_id
)

SELECT 
    COUNT(*) AS total_customers,
    SUM(CASE WHEN order_count = 1 THEN 1 ELSE 0 END) AS one_time_buyers,
    SUM(CASE WHEN order_count > 1 THEN 1 ELSE 0 END) AS repeat_buyers,
    ROUND(
        SUM(CASE WHEN order_count > 1 THEN 1 ELSE 0 END) / COUNT(*) * 100, 
        2
    ) AS repeat_rate_pct,
    ROUND(AVG(order_count), 2) AS avg_orders_per_customer
FROM customer_orders;


-- AOV + Revenue by Segment
WITH order_level AS (
    SELECT order_id, customer_unique_id, order_purchase_timestamp, payment_value
    FROM (
        SELECT 
            order_id,
            customer_unique_id,
            order_purchase_timestamp,
            payment_value,
            ROW_NUMBER() OVER (
                PARTITION BY order_id 
                ORDER BY order_purchase_timestamp DESC
            ) AS rn
        FROM transactions_cleaned
        WHERE customer_unique_id IS NOT NULL
          AND payment_value IS NOT NULL
    ) t
    WHERE rn = 1
),

rfm_base AS (
    SELECT 
        customer_unique_id,
        DATEDIFF(
            (SELECT DATE_ADD(MAX(order_purchase_timestamp), INTERVAL 1 DAY)
             FROM order_level),
            MAX(order_purchase_timestamp)
        ) AS recency,
        COUNT(DISTINCT order_id) AS frequency,
        ROUND(SUM(payment_value), 2) AS monetary
    FROM order_level
    GROUP BY customer_unique_id
),

ranked AS (
    SELECT 
        customer_unique_id,
        frequency,
        monetary,
        ROW_NUMBER() OVER (ORDER BY recency ASC, customer_unique_id ASC) AS r_rank,
        ROW_NUMBER() OVER (ORDER BY frequency ASC, customer_unique_id ASC) AS f_rank,
        ROW_NUMBER() OVER (ORDER BY monetary ASC, customer_unique_id ASC) AS m_rank
    FROM rfm_base
),

scored AS (
    SELECT 
        customer_unique_id,
        frequency,
        monetary,
        ROUND(monetary / frequency, 2) AS aov,
        (5 - NTILE(4) OVER (ORDER BY r_rank ASC)) AS r_score,
        NTILE(4) OVER (ORDER BY f_rank ASC) AS f_score,
        NTILE(4) OVER (ORDER BY m_rank ASC) AS m_score
    FROM ranked
),

segments AS (
    SELECT 
        customer_unique_id,
        monetary,
        aov,
        CASE 
            WHEN r_score = 4 AND f_score >= 3 AND m_score >= 3 THEN 'Champions'
            WHEN r_score >= 3 AND f_score >= 2 THEN 'Loyal Customers'
            WHEN r_score <= 2 AND f_score >= 3 AND m_score >= 3 THEN 'Cant Lose'
            WHEN r_score <= 2 AND f_score >= 2 THEN 'At-Risk'
            WHEN r_score <= 2 AND f_score <= 2 AND m_score <= 2 THEN 'Hibernating'
            ELSE 'Regular'
        END AS segment
    FROM scored
)

SELECT 
    segment,
    COUNT(*) AS customers,
    ROUND(SUM(monetary), 2) AS revenue,
    ROUND(AVG(aov), 2) AS avg_aov,
    ROUND(MIN(aov), 2) AS min_aov,
    ROUND(MAX(aov), 2) AS max_aov
FROM segments
GROUP BY segment
ORDER BY revenue DESC;

-- Delivery Performance vs Customer Satisfaction
WITH order_level AS (
    SELECT order_id, delivery_delay, review_score
    FROM (
        SELECT 
            order_id,
            delivery_delay,
            review_score,
            ROW_NUMBER() OVER (
                PARTITION BY order_id 
                ORDER BY order_purchase_timestamp DESC
            ) AS rn
        FROM transactions_cleaned
        WHERE delivery_delay IS NOT NULL
          AND review_score IS NOT NULL
    ) t
    WHERE rn = 1
)

SELECT 
    COUNT(*) AS total_orders,
    SUM(CASE WHEN delivery_delay > 0 THEN 1 ELSE 0 END) AS late_orders,
    ROUND(
        SUM(CASE WHEN delivery_delay > 0 THEN 1 ELSE 0 END) / COUNT(*) * 100, 
        2
    ) AS late_delivery_pct,
    ROUND(AVG(CASE WHEN delivery_delay > 0 THEN review_score END), 2) AS avg_review_late,
    ROUND(AVG(CASE WHEN delivery_delay <= 0 THEN review_score END), 2) AS avg_review_ontime
FROM order_level;

-- Review Score by Delay Bucket
WITH order_level AS (
    SELECT order_id, delivery_delay, review_score
    FROM (
        SELECT 
            order_id,
            delivery_delay,
            review_score,
            ROW_NUMBER() OVER (
                PARTITION BY order_id 
                ORDER BY order_purchase_timestamp DESC
            ) AS rn
        FROM transactions_cleaned
        WHERE delivery_delay IS NOT NULL
          AND review_score IS NOT NULL
    ) t
    WHERE rn = 1
)

SELECT 
    CASE 
        WHEN delivery_delay <= 0 THEN 'Early / On-Time'
        WHEN delivery_delay <= 5 THEN '1-5 Days Late'
        WHEN delivery_delay <= 10 THEN '6-10 Days Late'
        WHEN delivery_delay <= 20 THEN '11-20 Days Late'
        ELSE '20+ Days Late'
    END AS delay_bucket,
    COUNT(*) AS orders,
    ROUND(AVG(review_score), 2) AS avg_review
FROM order_level
GROUP BY delay_bucket
ORDER BY avg_review DESC;

-- Top Product Categories
SELECT 
    Product_category_name_english AS category,
    COUNT(DISTINCT order_id) AS orders,
    COUNT(order_item_id) AS items_sold,
    ROUND(SUM(price), 2) AS revenue,
    ROUND(AVG(price), 2) AS avg_selling_price,
    ROUND(AVG(review_score), 2) AS avg_review
FROM transactions_cleaned
WHERE Product_category_name_english IS NOT NULL
  AND price IS NOT NULL
GROUP BY Product_category_name_english
ORDER BY revenue DESC
LIMIT 10;

-- Top States by Revenue
WITH order_level AS (
    SELECT order_id, customer_unique_id, customer_state, order_purchase_timestamp, payment_value
    FROM (
        SELECT 
            order_id,
            customer_unique_id,
            customer_state,
            order_purchase_timestamp,
            payment_value,
            ROW_NUMBER() OVER (
                PARTITION BY order_id 
                ORDER BY order_purchase_timestamp DESC
            ) AS rn
        FROM transactions_cleaned
        WHERE customer_state IS NOT NULL
          AND payment_value IS NOT NULL
    ) t
    WHERE rn = 1
)

SELECT 
    customer_state AS state,
    COUNT(DISTINCT customer_unique_id) AS customers,
    COUNT(DISTINCT order_id) AS orders,
    ROUND(SUM(payment_value), 2) AS revenue,
    ROUND(SUM(payment_value) / COUNT(DISTINCT order_id), 2) AS aov
FROM order_level
GROUP BY customer_state
ORDER BY revenue DESC
LIMIT 10;


-- Top Sellers by Revenue
SELECT 
    seller_id,
    COUNT(DISTINCT order_id) AS orders,
    COUNT(order_item_id) AS items_sold,
    ROUND(SUM(price), 2) AS revenue,
    ROUND(AVG(price), 2) AS avg_price,
    COUNT(DISTINCT customer_unique_id) AS customers
FROM transactions_cleaned
WHERE seller_id IS NOT NULL
  AND price IS NOT NULL
GROUP BY seller_id
ORDER BY revenue DESC
LIMIT 10;

-- Payment Methods Analysis
WITH order_level AS (
    SELECT order_id, payment_type, payment_installments, payment_value
    FROM (
        SELECT 
            order_id,
            payment_type,
            payment_installments,
            payment_value,
            ROW_NUMBER() OVER (
                PARTITION BY order_id 
                ORDER BY order_purchase_timestamp DESC
            ) AS rn
        FROM transactions_cleaned
        WHERE payment_value IS NOT NULL
    ) t
    WHERE rn = 1
)

SELECT 
    payment_type,
    COUNT(DISTINCT order_id) AS orders,
    ROUND(SUM(payment_value), 2) AS revenue,
    ROUND(AVG(payment_value), 2) AS avg_payment,
    ROUND(AVG(payment_installments), 2) AS avg_installments
FROM order_level
GROUP BY payment_type
ORDER BY revenue DESC;


-- Cohort Retention Analysis
WITH customer_first_purchase AS (
    SELECT 
        customer_unique_id,
        MIN(order_purchase_timestamp) AS first_purchase
    FROM transactions_cleaned
    WHERE customer_unique_id IS NOT NULL
    GROUP BY customer_unique_id
),

cohort_data AS (
    SELECT 
        t.customer_unique_id,
        DATE_FORMAT(c.first_purchase, '%Y-%m') AS cohort_month,
        TIMESTAMPDIFF(
            MONTH, 
            c.first_purchase, 
            t.order_purchase_timestamp
        ) AS cohort_period
    FROM transactions_cleaned t
    JOIN customer_first_purchase c 
        ON t.customer_unique_id = c.customer_unique_id
    WHERE t.customer_unique_id IS NOT NULL
),

cohort_counts AS (
    SELECT 
        cohort_month,
        cohort_period,
        COUNT(DISTINCT customer_unique_id) AS customers
    FROM cohort_data
    WHERE cohort_period >= 0
    GROUP BY cohort_month, cohort_period
),

cohort_pivot AS (
    SELECT 
        cohort_month,
        MAX(CASE WHEN cohort_period = 0 THEN customers END) AS month_0,
        MAX(CASE WHEN cohort_period = 1 THEN customers END) AS month_1,
        MAX(CASE WHEN cohort_period = 2 THEN customers END) AS month_2,
        MAX(CASE WHEN cohort_period = 3 THEN customers END) AS month_3,
        MAX(CASE WHEN cohort_period = 4 THEN customers END) AS month_4,
        MAX(CASE WHEN cohort_period = 5 THEN customers END) AS month_5
    FROM cohort_counts
    GROUP BY cohort_month
)

SELECT 
    cohort_month,
    month_0,
    ROUND(month_1 / month_0 * 100, 1) AS month_1_pct,
    ROUND(month_2 / month_0 * 100, 1) AS month_2_pct,
    ROUND(month_3 / month_0 * 100, 1) AS month_3_pct,
    ROUND(month_4 / month_0 * 100, 1) AS month_4_pct,
    ROUND(month_5 / month_0 * 100, 1) AS month_5_pct
FROM cohort_pivot
ORDER BY cohort_month;


-- Customer 360 Table
WITH order_level AS (
    SELECT order_id, customer_unique_id, order_purchase_timestamp, payment_value, review_score, delivery_delay
    FROM (
        SELECT 
            order_id,
            customer_unique_id,
            order_purchase_timestamp,
            payment_value,
            review_score,
            delivery_delay,
            ROW_NUMBER() OVER (
                PARTITION BY order_id 
                ORDER BY order_purchase_timestamp DESC
            ) AS rn
        FROM transactions_cleaned
        WHERE customer_unique_id IS NOT NULL
          AND payment_value IS NOT NULL
    ) t
    WHERE rn = 1
),

customer_metrics AS (
    SELECT 
        customer_unique_id,
        COUNT(DISTINCT order_id) AS total_orders,
        ROUND(SUM(payment_value), 2) AS total_revenue,
        MAX(order_purchase_timestamp) AS last_purchase,
        ROUND(AVG(review_score), 2) AS avg_review,
        ROUND(AVG(delivery_delay), 2) AS avg_delay
    FROM order_level
    GROUP BY customer_unique_id
)

SELECT * FROM customer_metrics LIMIT 10;


-- Final Business KPIs
WITH order_level AS (
    SELECT order_id, customer_unique_id, order_purchase_timestamp, payment_value
    FROM (
        SELECT 
            order_id,
            customer_unique_id,
            order_purchase_timestamp,
            payment_value,
            ROW_NUMBER() OVER (
                PARTITION BY order_id 
                ORDER BY order_purchase_timestamp DESC
            ) AS rn
        FROM transactions_cleaned
        WHERE customer_unique_id IS NOT NULL
          AND payment_value IS NOT NULL
    ) t
    WHERE rn = 1
),

customer_metrics AS (
    SELECT 
        customer_unique_id,
        COUNT(DISTINCT order_id) AS total_orders,
        SUM(payment_value) AS total_revenue,
        DATEDIFF(
            (SELECT DATE_ADD(MAX(order_purchase_timestamp), INTERVAL 1 DAY) FROM order_level),
            MAX(order_purchase_timestamp)
        ) AS recency
    FROM order_level
    GROUP BY customer_unique_id
)

SELECT 
    ROUND(SUM(total_revenue), 2) AS total_revenue,
    SUM(total_orders) AS total_orders,
    COUNT(*) AS total_customers,
    ROUND(SUM(total_revenue) / SUM(total_orders), 2) AS aov,
    ROUND(
        SUM(CASE WHEN total_orders > 1 THEN 1 ELSE 0 END) / COUNT(*) * 100, 
        2
    ) AS repeat_rate_pct,
    ROUND(
        SUM(CASE WHEN recency > 180 THEN 1 ELSE 0 END) / COUNT(*) * 100, 
        2
    ) AS churn_rate_pct
FROM customer_metrics;


# ==============================================================

