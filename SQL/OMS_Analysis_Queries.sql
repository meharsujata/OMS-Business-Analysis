-- =====================================================
-- PROJECT: Online Retail Order Management System (OMS)
-- PURPOSE: Analyse order volumes, delivery issues,
-- cancellations, sales, and potential system improvements.
-- DATABASE: Order_Management_System
-- TABLE: public.oms_orders
-- =====================================================


-- Query 1: How many orders are in the OMS dataset?

SELECT
    COUNT(*) AS total_orders
FROM public.oms_orders;


-- Query 2: Which product categories have the most orders?

SELECT
    category_name,
    COUNT(*) AS total_orders
FROM public.oms_orders
GROUP BY category_name
ORDER BY total_orders DESC;


-- Query 3: Which product categories generate the most sales?

SELECT
    category_name,
    SUM(sales_per_order) AS total_sales
FROM public.oms_orders
GROUP BY category_name
ORDER BY total_sales DESC;


-- Query 4: What is the breakdown of delivery outcomes?

SELECT
    delivery_status,
    COUNT(*) AS total_orders
FROM public.oms_orders
GROUP BY delivery_status
ORDER BY total_orders DESC;


-- Query 5: Which shipping types have more than
-- 1,000 late orders?

SELECT
    shipping_type,
    COUNT(*) AS total_late_orders
FROM public.oms_orders
WHERE delivery_status = 'Late delivery'
GROUP BY shipping_type
HAVING COUNT(*) > 1000
ORDER BY total_late_orders DESC;


-- Query 6: How should delivery outcomes be classified
-- for business action?

SELECT DISTINCT
    delivery_status,
    CASE
        WHEN delivery_status = 'Late delivery'
            THEN 'Needs Improvement'
        WHEN delivery_status = 'Shipping canceled'
            THEN 'Needs Investigation'
        ELSE 'Acceptable'
    END AS business_action
FROM public.oms_orders
ORDER BY delivery_status;


-- Query 7: Which customer regions have the most
-- late deliveries?

SELECT
    customer_region,
    COUNT(*) AS late_orders
FROM public.oms_orders
WHERE delivery_status = 'Late delivery'
GROUP BY customer_region
ORDER BY late_orders DESC;


-- Query 8: Which shipping types have the most
-- cancelled orders?

SELECT
    shipping_type,
    COUNT(*) AS cancelled_orders
FROM public.oms_orders
WHERE delivery_status = 'Shipping canceled'
GROUP BY shipping_type
ORDER BY cancelled_orders DESC;


-- Query 9: Which shipping types have the most orders
-- exceeding scheduled shipping days?

SELECT
    shipping_type,
    COUNT(*) AS delayed_orders
FROM public.oms_orders
WHERE days_for_shipment_real > days_for_shipment_scheduled
GROUP BY shipping_type
ORDER BY delayed_orders DESC;

-- Business Finding:
-- Standard Class has the highest count of orders
-- exceeding scheduled shipping days (26,293).
-- Same Day has the lowest count (3,015).
--
-- Recommendation:
-- Investigate Standard Class scheduling and fulfilment.
-- These are counts, not delay rates; compare against
-- total orders per shipping type before drawing conclusions.


-- Query 10: How can orders be linked with geographic data?

SELECT
    o.customer_state,
    g.latitude,
    g.longitude,
    COUNT(*) AS total_orders
FROM public.oms_orders AS o
JOIN public.state_geography AS g
    ON TRIM(o.customer_state) = TRIM(g.state_name)
GROUP BY
    o.customer_state,
    g.latitude,
    g.longitude
ORDER BY total_orders DESC;
