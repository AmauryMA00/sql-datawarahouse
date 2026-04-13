PRINT '-- DELETING THE TABLE: silver.erp_loc_a101'
TRUNCATE TABLE silver.erp_loc_a101
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
