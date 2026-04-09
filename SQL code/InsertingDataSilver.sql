-- Cleaning the table crm_cust_info

-- Now Ill be looking for nulls and duplicates
-- Expectation: No result
/*
SELECT cst_id, COUNT(*)
FROM bronze.crm_cust_info
GROUP BY cst_id
HAVING COUNT(*) > 1 OR cst_id IS NULL
*/



-- Check for unwanted spaces
-- Expectation: No results
/*
SELECT *
FROM bronze.crm_cust_info
WHERE cst_firstname != TRIM(cst_firstname)
*/

-- We can see that there is some cst_id duplicates and also with nulls.
-- We deleted all the blank spaces, also transformed the chars to fully visible text.And transformed the nulls.
--With the following query we can get rid of the nulls and duplicates
TRUNCATE TABLE silver.crm_cust_info; 
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

