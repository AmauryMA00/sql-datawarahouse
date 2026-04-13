/*
----- EXPLANATION
-- This script loads the data from a certain route. The procedure does not accept any parameters, and also does 
-- not return any value too.

Example:
EXECUTION silver.load_silver
EXEC silver.load_silver
-
Both of them work, the second one only uses an abreviation
*/

CREATE OR ALTER PROCEDURE silver.load_silver AS 
BEGIN
	DECLARE @start_time DATETIME , @end_time DATETIME, @start_time_batch DATETIME, @end_time_batch DATETIME;
	BEGIN TRY
		SET @start_time_batch = GETDATE();
		-- LOAD DATA
		PRINT '================================================================================='
		PRINT 'Loading silver layout'
		PRINT '================================================================================='
	
		-- CRM
		PRINT '---------------------------------------------------------------------------------'
		PRINT 'Loading CRM Tables'
		PRINT '---------------------------------------------------------------------------------'
		
		SET @start_time = GETDATE();
		PRINT '## Truncating table: silver.crm_cust_info'
		TRUNCATE TABLE silver.crm_cust_info; -- Delete the data
		PRINT '-- DELETING THE TABLE: silver.crm_cust_info'
		PRINT '-- INSERTING DATA TO THE TABLE: silver.crm_cust_info'
		
		INSERT INTO silver.crm_cust_info (
		cst_id,
		cst_key,
		cst_firstname,
		cst_lastname,
		cst_material_status,
		cst_gnder,
		cst_create_date)

		SELECT 
		cst_id,
		cst_key,
		TRIM(cst_firstname) AS cst_firstname,
		TRIM(cst_lastname) AS cst_lastname,
		CASE WHEN UPPER(TRIM(cst_material_status)) = 'S' THEN 'Single'
			WHEN UPPER((cst_material_status)) = 'M' THEN 'Married'
			else 'n/a'
		END cst_material_status,
		CASE WHEN UPPER(TRIM(cst_gnder)) = 'F' THEN 'Female'
			WHEN UPPER((cst_gnder)) = 'M' THEN 'Male'
			else 'n/a'
		END cst_gndr,
		cst_create_date
		FROM (
			SELECT
			*,
			ROW_NUMBER() OVER (PARTITION BY cst_id ORDER BY cst_create_date DESC) as flag_last
			FROM bronze.crm_cust_info
			WHERE cst_id IS NOT NULL
		)t WHERE flag_last = 1
		SET @end_time = GETDATE();
		PRINT '## Load duration ' + CAST(DATEDIFF(millisecond,@start_time,@end_time) AS NVARCHAR) + ' ms'
		
		
		PRINT '----------------------------------'
		SET @start_time = GETDATE();
		PRINT '## Truncating table: silver.crm_prd_info'
		TRUNCATE TABLE silver.crm_prd_info; -- Delete the data
		PRINT '-- INSERTING DATA TO THE TABLE: silver.crm_prd_info'
		
		INSERT INTO silver.crm_prd_info (
			prd_id,
			cat_id,
			prd_key,
			prd_nm,
			prd_cost,
			prd_line,
			prd_start_dt,
			prd_end_dt
		)

		SELECT 
		prd_id,
		REPLACE(SUBSTRING(prd_key,1,5),'-','_') AS cat_id, -- We need to separate the value in 2 columns, because in this table its combined the data
		SUBSTRING(prd_key,7,LEN(prd_key)) AS prd_key,
		prd_nm,
		ISNULL(prd_cost,0) AS prd_cost, -- Typical changing nulls
		CASE UPPER(TRIM(prd_line))  -- Used to show better the description/type of the product
			 WHEN 'M' THEN 'Mountain'
			 WHEN 'R' THEN 'Road' 
			 WHEN 'S' THEN 'Sport' 
			 WHEN 'T' THEN 'Touring'
			 ELSE 'n/a'
		END AS prd_line,
		CAST(prd_start_dt AS DATE) AS prd_start_dt, -- Previously it was DATETIME, and we dont need the time here
		CAST(LEAD(prd_start_dt) OVER (PARTITION BY prd_key ORDER BY prd_start_dt)-1 AS DATE) AS prd_end_dt --This line was necessary due to the errors in the prd_end_dt
		FROM bronze.crm_prd_info

		SET @end_time = GETDATE();
		PRINT '## Load duration ' + CAST(DATEDIFF(millisecond,@start_time,@end_time) AS NVARCHAR) + ' ms'
		
		
		PRINT '----------------------------------'
		SET @start_time = GETDATE();
		PRINT '## Truncating table: silver.crm_sales_details'
		TRUNCATE TABLE silver.crm_sales_details; -- Delete the data
		PRINT '-- INSERTING DATA TO THE TABLE: silver.crm_sales_details'
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
		SET @end_time = GETDATE();
		PRINT '## Load duration ' + CAST(DATEDIFF(millisecond,@start_time,@end_time) AS NVARCHAR) + ' ms'
		
		
		PRINT '----------------------------------'
		-- ERP
		PRINT '---------------------------------------------------------------------------------'
		PRINT 'Loading ERP Tables'
		PRINT '---------------------------------------------------------------------------------'
		
		SET @start_time = GETDATE();
		PRINT '## Truncating table: silver.erp_loc_a101'
		TRUNCATE TABLE silver.erp_loc_a101; -- Delete the data
		PRINT '-- INSERTING DATA TO THE TABLE: silver.erp_loc_a101'
		
		INSERT INTO silver.erp_loc_a101(
			cid,
			cntry,
			cntryCode
		)

		SELECT
		REPLACE(cid,'-','') AS cid,
		CASE 
		 WHEN TRIM(cntry) = 'DE' THEN 'Germany'
		 WHEN TRIM(cntry) ='USA' THEN 'United States'
		 WHEN TRIM(cntry) = 'US' THEN 'United States'
		 WHEN TRIM(cntry) = '' THEN 'n/a'
		 WHEN TRIM(cntry) IS NULL THEN 'n/a'
		 ELSE TRIM(cntry)
		END AS cntry,
		CASE 
		 WHEN TRIM(cntry) = 'Germany' THEN 'DE'
		 WHEN TRIM(cntry) ='United States' THEN 'US'
		 WHEN TRIM(cntry) = 'Australia' THEN 'AU'
		 WHEN TRIM(cntry) = 'United Kingdom' THEN 'GB'
		 WHEN TRIM(cntry) = 'Canada' THEN 'CA'
		 WHEN TRIM(cntry) = 'France' THEN 'FR'
		 WHEN TRIM(cntry) = 'US' THEN 'US'
		 WHEN TRIM(cntry) IS NULL THEN 'n/a'
		 ELSE TRIM(cntry)
		END AS cntryCode
		FROM bronze.erp_loc_a101

		SET @end_time = GETDATE();
		PRINT '## Load duration ' + CAST(DATEDIFF(millisecond,@start_time,@end_time) AS NVARCHAR) + ' ms'
		PRINT '----------------------------------'


		SET @start_time = GETDATE();
		PRINT '## Truncating table: silver.erp_cust_az12'
		TRUNCATE TABLE silver.erp_cust_az12; -- Delete the data
		PRINT '-- INSERTING DATA TO THE TABLE: silver.erp_cust_az12'
		INSERT INTO silver.erp_cust_az12 (
			cid,
			bdate,
			gen
		)

		SELECT 
		CASE 
		 WHEN TRIM(cid) LIKE 'NAS%' THEN SUBSTRING(cid,4,LEN(cid))
		 ELSE TRIM(cid)
		END AS cid,
		bdate,
		CASE
		 WHEN UPPER(gen) = 'MALE' THEN 'M'
		 WHEN UPPER(gen) = 'FEMALE' THEN 'F'
		 WHEN UPPER(gen) = '' THEN 'n/a'
		 WHEN gen IS NULL THEN 'n/a'
		 ELSE gen
		END AS gen
		FROM bronze.erp_cust_az12;

		SET @end_time = GETDATE();
		PRINT '## Load duration ' + CAST(DATEDIFF(millisecond,@start_time,@end_time) AS NVARCHAR) + ' ms'
		PRINT '----------------------------------'
		

		SET @start_time = GETDATE();
		PRINT '## Truncating table: silver.erp_px_cat_g1v2'
		TRUNCATE TABLE silver.erp_px_cat_g1v2; -- Delete the data
		PRINT '-- INSERTING DATA TO THE TABLE: silver.erp_px_cat_g1v2'
		INSERT INTO silver.erp_px_cat_g1v2 (
			id,
			cat,
			subcat,
			maintenance
		)


		SELECT
			id,
			cat,
			subcat,
			maintenance
		FROM bronze.erp_px_cat_g1v2

		SET @end_time = GETDATE();
		PRINT '## Load duration ' + CAST(DATEDIFF(millisecond,@start_time,@end_time) AS NVARCHAR) + ' ms'
		PRINT '----------------------------------'

		SET @end_time_batch = GETDATE();
		PRINT '===================================================================================='
		PRINT '## SILVER LAYER LOAD IS COMPLETED'
		PRINT '## The whole load duration is: ' + CAST(DATEDIFF(millisecond,@start_time_batch,@end_time_batch) AS NVARCHAR) + ' ms'
		PRINT '===================================================================================='
		
	END TRY
	BEGIN CATCH
		-- In case of errors, these block will act
		PRINT '===================================================================================='
		PRINT 'Error loading silver layer' + CAST(ERROR_NUMBER() AS NVARCHAR);
		PRINT 'Error loading silver layer' + CAST(ERROR_STATE() AS NVARCHAR);
		PRINT '===================================================================================='
	END CATCH
END