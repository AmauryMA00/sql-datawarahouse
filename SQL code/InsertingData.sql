-- LOAD DATA

-- CRM

TRUNCATE TABLE bronze.crm_cust_info; -- Delete the data
BULK INSERT bronze.crm_cust_info -- Insert the data
FROM 'C:\Users\ben10\Documents\Projects\SQL\sql-datawarahouse\datasets\crm\cust_info.csv'
WITH (
 FIRSTROW = 2,
 FIELDTERMINATOR = ',',
 TABLOCK 
);

TRUNCATE TABLE bronze.crm_prd_info; -- Delete the data
BULK INSERT bronze.crm_prd_info -- Insert the data
FROM 'C:\Users\ben10\Documents\Projects\SQL\sql-datawarahouse\datasets\crm\prd_info.csv'
WITH (
 FIRSTROW = 2,
 FIELDTERMINATOR = ',',
 TABLOCK 
);

TRUNCATE TABLE bronze.crm_sales_details; -- Delete the data
BULK INSERT bronze.crm_sales_details -- Insert the data
FROM 'C:\Users\ben10\Documents\Projects\SQL\sql-datawarahouse\datasets\crm\sales_details.csv'
WITH (
 FIRSTROW = 2,
 FIELDTERMINATOR = ',',
 TABLOCK 
);


-- ERP

TRUNCATE TABLE bronze.erp_cust_a101; -- Delete the data
BULK INSERT bronze.erp_cust_a101 -- Insert the data
FROM 'C:\Users\ben10\Documents\Projects\SQL\sql-datawarahouse\datasets\erp\LOC_A101.csv'
WITH (
 FIRSTROW = 2,
 FIELDTERMINATOR = ',',
 TABLOCK 
);

TRUNCATE TABLE bronze.erp_cust_az12; -- Delete the data
BULK INSERT bronze.erp_cust_az12 -- Insert the data
FROM 'C:\Users\ben10\Documents\Projects\SQL\sql-datawarahouse\datasets\erp\CUST_AZ12.csv'
WITH (
 FIRSTROW = 2,
 FIELDTERMINATOR = ',',
 TABLOCK 
);

TRUNCATE TABLE bronze.erp_px_cat_g1v2; -- Delete the data
BULK INSERT bronze.erp_px_cat_g1v2 -- Insert the data
FROM 'C:\Users\ben10\Documents\Projects\SQL\sql-datawarahouse\datasets\erp\PX_CAT_G1V2.csv'
WITH (
 FIRSTROW = 2,
 FIELDTERMINATOR = ',',
 TABLOCK 
);