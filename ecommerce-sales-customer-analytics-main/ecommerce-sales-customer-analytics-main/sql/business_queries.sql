-- E-Commerce Sales & Customer Analytics
-- Load data/cleaned_online_retail.csv into a SQL table named analytical_sales.
-- The CSV uses one row per valid completed-sales transaction line item.


-- 1. Total revenue
SELECT ROUND(SUM(Revenue), 2) AS total_revenue
FROM analytical_sales;

-- 2. Total orders, customers, and units
SELECT COUNT(DISTINCT InvoiceNo) AS total_orders,
       COUNT(DISTINCT CustomerID) AS total_customers,
       SUM(Quantity) AS total_units_sold
FROM analytical_sales ;

-- 3. Monthly revenue and orders
SELECT YearMonth,
       ROUND(SUM(Revenue), 2) AS monthly_revenue,
       COUNT(DISTINCT InvoiceNo) AS monthly_orders
FROM analytical_sales
GROUP BY YearMonth
ORDER BY YearMonth;

-- 4. Top products by revenue
SELECT StockCode, Description,
       ROUND(SUM(Revenue), 2) AS revenue,
       SUM(Quantity) AS units_sold
FROM analytical_sales
GROUP BY StockCode, Description
ORDER BY revenue DESC
LIMIT 10;

-- 5. Revenue and average order value by country
SELECT Country,
       ROUND(SUM(Revenue), 2) AS revenue,
       COUNT(DISTINCT InvoiceNo) AS orders,
       ROUND(SUM(Revenue) / NULLIF(COUNT(DISTINCT InvoiceNo), 0), 2) AS average_order_value
FROM analytical_sales
GROUP BY Country
ORDER BY revenue DESC;

-- 6. Top customers by revenue
SELECT CustomerID,
       ROUND(SUM(Revenue), 2) AS customer_revenue,
       COUNT(DISTINCT InvoiceNo) AS orders,
       SUM(Quantity) AS units
FROM analytical_sales
WHERE CustomerID IS NOT NULL
GROUP BY CustomerID
ORDER BY customer_revenue DESC
LIMIT 20;

-- 7. Overall average order value using an order-level CTE
WITH order_totals AS (
    SELECT InvoiceNo, SUM(Revenue) AS order_revenue
    FROM analytical_sales
    GROUP BY InvoiceNo
)
SELECT ROUND(AVG(order_revenue), 2) AS average_order_value
FROM order_totals;

-- 8. Repeat versus one-time customers
WITH customer_orders AS (
    SELECT CustomerID, COUNT(DISTINCT InvoiceNo) AS order_count
    FROM analytical_sales
    WHERE CustomerID IS NOT NULL
    GROUP BY CustomerID
)
SELECT CASE WHEN order_count > 1 THEN 'Repeat' ELSE 'One-time' END AS customer_type,
       COUNT(*) AS customers,
       ROUND(100.0 * COUNT(*) / SUM(COUNT(*)) OVER (), 2) AS customer_share
FROM customer_orders
GROUP BY CASE WHEN order_count > 1 THEN 'Repeat' ELSE 'One-time' END;

-- 9. Product revenue ranking with a window function
WITH product_revenue AS (
    SELECT StockCode, Description, SUM(Revenue) AS revenue
    FROM analytical_sales
    GROUP BY StockCode, Description
)
SELECT StockCode, Description,
       ROUND(revenue, 2) AS revenue,
       DENSE_RANK() OVER (ORDER BY revenue DESC) AS revenue_rank
FROM product_revenue
ORDER BY revenue_rank
LIMIT 20;

-- 10. Customer revenue ranking and share of revenue
WITH customer_revenue AS (
    SELECT CustomerID, SUM(Revenue) AS revenue
    FROM analytical_sales
    WHERE CustomerID IS NOT NULL
    GROUP BY CustomerID
)
SELECT CustomerID,
       ROUND(revenue, 2) AS revenue,
       DENSE_RANK() OVER (ORDER BY revenue DESC) AS customer_rank,
       ROUND(100.0 * revenue / SUM(revenue) OVER (), 2) AS revenue_share_percent
FROM customer_revenue
ORDER BY customer_rank;

-- 11. RFM-style segment summary. customer_metrics is created by the notebook.
SELECT Segment, COUNT(*) AS customers,
       ROUND(SUM(Monetary), 2) AS revenue,
       ROUND(AVG(Frequency), 2) AS average_orders
FROM customer_metrics
GROUP BY Segment
ORDER BY revenue DESC;
