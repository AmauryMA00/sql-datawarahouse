
-- With this select we can see that the difference between the sls_order_dt and the sls_ship_dt is allways 7 days
DECLARE @avg_dias_order_ship INT;

SELECT @avg_dias_order_ship = AVG(DATEDIFF(day,
    CAST(CAST(sls_order_dt AS CHAR(8)) AS DATE),
    CAST(CAST(sls_ship_dt  AS CHAR(8)) AS DATE)
))
FROM bronze.crm_sales_details
WHERE LEN(sls_order_dt) = 8 AND LEN(sls_ship_dt) = 8;

-- Result: 7
INSERT INTO silver.crm_sales_details (
sls_ord_num,
sls_prd_key,
sls_cust_id,
sls_order_dt,
sls_ship_dt,
sls_due_dt,
sls_sales,
sls_quantity,
sls_price
)

SELECT 
sls_ord_num,
sls_prd_key,
sls_cust_id,
CASE LEN(sls_order_dt)
    WHEN 8 THEN CAST(CAST(sls_order_dt AS NVARCHAR(8)) AS DATE)
    ELSE DATEADD(DAY,-@avg_dias_order_ship,CAST(CAST(sls_ship_dt AS NVARCHAR(8)) AS DATE))
END AS sls_order_dt,
CAST(CAST(sls_ship_dt AS NVARCHAR(8)) AS DATE) AS sls_ship_dt,
CAST(CAST(sls_due_dt AS NVARCHAR(8)) AS DATE) AS sls_due_dt,
CASE WHEN sls_sales IS NULL OR sls_sales <= 0 OR sls_sales != sls_quantity * ABS(sls_price)
    THEN sls_quantity * ABS(sls_price)
    ELSE sls_sales
END AS sls_sales,
sls_quantity,
CASE WHEN sls_price IS NULL OR sls_price <= 0
    THEN sls_sales / NULLIF(sls_quantity,0)
    ELSE sls_price
END AS sls_price
FROM (
SELECT *
FROM bronze.crm_sales_details
WHERE LEN(sls_order_dt) = 8 AND LEN(sls_ship_dt) = 8
)t


--SELECT
--sls_ord_num,
--sls_prd_key,
--sls_cust_id,
--CAST(CAST(sls_order_dt AS NVARCHAR(8)) AS DATE),
--sls_ship_dt,
--sls_due_dt,
--sls_sales,
--sls_quantity,
--sls_price
--FROM bronze.crm_sales_details;


--SELECT sls_ord_num,COUNT(sls_ord_num)
--FROM bronze.crm_sales_details
--GROUP BY sls_ord_num, sls_prd_key
--HAVING COUNT(sls_ord_num) > 1

--SELECT *
--FROM bronze.crm_sales_details
--WHERE sls_ord_num = 'SO65337'

--SELECT *
--FROM bronze.crm_sales_details
--WHERE LEN(sls_order_dt) != 8 

--SELECT sls_sales,COUNT(*)
--FROM bronze.crm_sales_details
--WHERE sls_sales IS NULL OR sls_sales < 1
--GROUP BY sls_sales
--HAVING COUNT(*) > 1

--SELECT *
--FROM bronze.crm_sales_details
--WHERE sls_sales IS NULL AND sls_price IS NULL