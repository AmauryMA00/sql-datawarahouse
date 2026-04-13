PRINT '-- DELETING THE TABLE: silver.erp_cust_az12'
TRUNCATE TABLE silver.erp_cust_az12
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

--SELECT 
--LEN(cid),
--COUNT(*)
--FROM bronze.erp_cust_az12
--GROUP BY LEN(cid)
