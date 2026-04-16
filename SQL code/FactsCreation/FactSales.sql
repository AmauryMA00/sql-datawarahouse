CREATE VIEW gold.fact_sales AS
SELECT
crm_sales.sls_ord_num AS order_number,
dim_prd.product_key,
dim_cust.custom_key,
crm_sales.sls_order_dt AS order_date,
crm_sales.sls_ship_dt AS ship_date,
crm_sales.sls_due_dt AS due_date,
crm_sales.sls_sales AS sales,
crm_sales.sls_quantity AS quantity,
crm_sales.sls_price AS total_price
FROM silver.crm_sales_details AS crm_sales
LEFT JOIN gold.dim_products AS dim_prd
ON crm_sales.sls_prd_key = dim_prd.product_number
LEFT JOIN gold.dim_customers AS dim_cust
ON crm_sales.sls_cust_id = dim_cust.customer_id