/*
SQL Data Analysis Project: E-commerce Performance Insights
Database: DsFive (Standard E-commerce Schema)
*/

-- 1.For each device type, identify the top referral source by order count.
WITH ReferralSummary AS (
    SELECT 
        device_type,
        http_referer, 
        COUNT(order_id) AS order_count,
        RANK() OVER (PARTITION BY device_type ORDER BY COUNT(order_id) DESC) AS ranking
    FROM [dbo].[DsFive_orders] o
    INNER JOIN [dbo].[DsFive_website_sessions] s ON o.website_session_id = s.website_session_id
    WHERE s.http_referer IS NOT NULL
    GROUP BY device_type, http_referer
)
SELECT device_type, http_referer, order_count
FROM ReferralSummary
WHERE ranking = 1;


-- 2.Products (IDs 1, 2, 3) with total revenue exceeding $300,000.
SELECT 
    primary_product_id,
    SUM(price_usd) AS total_revenue
FROM [dbo].[DsFive_orders]
WHERE primary_product_id IN (1, 2, 3)
GROUP BY primary_product_id
HAVING SUM(price_usd) > 300000;


-- 3. Daily pageview counts per URL.
SELECT 
    CAST(created_at AS DATE) AS visit_date,
    pageview_url,
    COUNT(website_pageview_id) AS total_views
FROM [dbo].[DsFive_website_pageviews]
GROUP BY CAST(created_at AS DATE), pageview_url
ORDER BY visit_date DESC, total_views DESC;


-- 4.Total price per product and the overall average price across all products.
SELECT 
    product_id,
    SUM(price_usd) AS product_total_revenue,
    AVG(SUM(price_usd)) OVER() AS global_average_revenue
FROM [dbo].[DsFive_order_items] 
GROUP BY product_id;


-- 5.Sales vs. Refunds per product in 2013.
SELECT 
    p.product_name, 
    COUNT(o.order_id) AS total_orders, 
    COUNT(r.order_item_refund_id) AS total_refunds
FROM [dbo].[DsFive_products] AS p 
LEFT JOIN [dbo].[DsFive_orders] AS o ON o.primary_product_id = p.product_id 
LEFT JOIN [dbo].[DsFive_order_item_refunds] AS r ON r.order_id = o.order_id
WHERE YEAR(o.created_at) = 2013
GROUP BY p.product_name;