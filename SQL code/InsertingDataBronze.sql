/*
----- EXPLANATION
-- This script loads the data from a certain route. The procedure does not accept any parameters, and also does 
-- not return any value too.

Example:
EXECUTION bronze.load_bronze
EXEC bronze.load_bronze
-
Both of them work, the second one only uses an abreviation
*/


-- Creation of a SQL Procedure
CREATE OR ALTER PROCEDURE bronze.load_bronze AS 
BEGIN
	DECLARE @start_time DATETIME , @end_time DATETIME, @start_time_batch DATETIME, @end_time_batch DATETIME;
	BEGIN TRY
		SET @start_time_batch = GETDATE();
		-- LOAD DATA
		PRINT '================================================================================='
		PRINT 'Loading bronze layout'
		PRINT '================================================================================='
	
		-- CRM
		PRINT '---------------------------------------------------------------------------------'
		PRINT 'Loading CRM Tables'
		PRINT '---------------------------------------------------------------------------------'
		
		SET @start_time = GETDATE();
		PRINT '## Truncating table: bronze.crm_cust_info'
		TRUNCATE TABLE bronze.crm_cust_info; -- Delete the data
		BULK INSERT bronze.crm_cust_info -- Insert the data
		FROM 'C:\Users\ben10\Documents\Projects\SQL\sql-datawarahouse\datasets\crm\cust_info.csv'
		WITH (
		 FIRSTROW = 2,
		 FIELDTERMINATOR = ',',
		 TABLOCK 
		);
		SET @end_time = GETDATE();
		PRINT '## Load duration ' + CAST(DATEDIFF(millisecond,@start_time,@end_time) AS NVARCHAR) + ' ms'
		PRINT '----------------------------------'

		SET @start_time = GETDATE();
		PRINT '## Truncating table: bronze.crm_prd_info'
		TRUNCATE TABLE bronze.crm_prd_info; -- Delete the data
		BULK INSERT bronze.crm_prd_info -- Insert the data
		FROM 'C:\Users\ben10\Documents\Projects\SQL\sql-datawarahouse\datasets\crm\prd_info.csv'
		WITH (
		 FIRSTROW = 2,
		 FIELDTERMINATOR = ',',
		 TABLOCK 
		);
		SET @end_time = GETDATE();
		PRINT '## Load duration ' + CAST(DATEDIFF(millisecond,@start_time,@end_time) AS NVARCHAR) + ' ms'
		PRINT '----------------------------------'

		SET @start_time = GETDATE();
		PRINT '## Truncating table: bronze.crm_sales_details'
		TRUNCATE TABLE bronze.crm_sales_details; -- Delete the data
		BULK INSERT bronze.crm_sales_details -- Insert the data
		FROM 'C:\Users\ben10\Documents\Projects\SQL\sql-datawarahouse\datasets\crm\sales_details.csv'
		WITH (
		 FIRSTROW = 2,
		 FIELDTERMINATOR = ',',
		 TABLOCK 
		);
		SET @end_time = GETDATE();
		PRINT '## Load duration ' + CAST(DATEDIFF(millisecond,@start_time,@end_time) AS NVARCHAR) + ' ms'
		PRINT '----------------------------------'


		-- ERP
		PRINT '---------------------------------------------------------------------------------'
		PRINT 'Loading ERP Tables'
		PRINT '---------------------------------------------------------------------------------'
		
		SET @start_time = GETDATE();
		PRINT '## Truncating table: bronze.erp_cust_a101'
		TRUNCATE TABLE bronze.erp_cust_a101; -- Delete the data
		BULK INSERT bronze.erp_cust_a101 -- Insert the data
		FROM 'C:\Users\ben10\Documents\Projects\SQL\sql-datawarahouse\datasets\erp\LOC_A101.csv'
		WITH (
		 FIRSTROW = 2,
		 FIELDTERMINATOR = ',',
		 TABLOCK 
		);
		SET @end_time = GETDATE();
		PRINT '## Load duration ' + CAST(DATEDIFF(millisecond,@start_time,@end_time) AS NVARCHAR) + ' ms'
		PRINT '----------------------------------'

		SET @start_time = GETDATE();
		PRINT '## Truncating table: bronze.erp_cust_az12'
		TRUNCATE TABLE bronze.erp_cust_az12; -- Delete the data
		BULK INSERT bronze.erp_cust_az12 -- Insert the data
		FROM 'C:\Users\ben10\Documents\Projects\SQL\sql-datawarahouse\datasets\erp\CUST_AZ12.csv'
		WITH (
		 FIRSTROW = 2,
		 FIELDTERMINATOR = ',',
		 TABLOCK 
		);
		SET @end_time = GETDATE();
		PRINT '## Load duration ' + CAST(DATEDIFF(millisecond,@start_time,@end_time) AS NVARCHAR) + ' ms'
		PRINT '----------------------------------'
		
		SET @start_time = GETDATE();
		PRINT '## Truncating table: bronze.erp_px_cat_g1v2'
		TRUNCATE TABLE bronze.erp_px_cat_g1v2; -- Delete the data
		BULK INSERT bronze.erp_px_cat_g1v2 -- Insert the data
		FROM 'C:\Users\ben10\Documents\Projects\SQL\sql-datawarahouse\datasets\erp\PX_CAT_G1V2.csv'
		WITH (
		 FIRSTROW = 2,
		 FIELDTERMINATOR = ',',
		 TABLOCK 
		);
		SET @end_time = GETDATE();
		PRINT '## Load duration ' + CAST(DATEDIFF(millisecond,@start_time,@end_time) AS NVARCHAR) + ' ms'
		PRINT '----------------------------------'
		SET @end_time_batch = GETDATE();
		PRINT '===================================================================================='
		PRINT '## BRONZE LAYER LOAD IS COMPLETED'
		PRINT '## The whole load duration is: ' + CAST(DATEDIFF(millisecond,@start_time_batch,@end_time_batch) AS NVARCHAR) + ' ms'
		PRINT '===================================================================================='
		
	END TRY
	BEGIN CATCH
		-- In case of errors, these block will act
		PRINT '===================================================================================='
		PRINT 'Error loading bronze layer' + CAST(ERROR_NUMBER() AS NVARCHAR);
		PRINT 'Error loading bronze layer' + CAST(ERROR_STATE() AS NVARCHAR);
		PRINT '===================================================================================='
	END CATCH
END