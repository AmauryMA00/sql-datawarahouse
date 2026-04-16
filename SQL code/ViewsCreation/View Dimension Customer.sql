CREATE VIEW gold.dim_customers AS
SELECT 
ROW_NUMBER() OVER(ORDER BY cst_id) AS custom_key,
ci.cst_id AS customer_id, 
ci.cst_key AS customer_number,
ci.cst_firstname AS first_name,
ci.cst_lastname AS last_name,
CASE 
	WHEN ci.cst_gnder = 'n/a' AND ci_birth.gen = 'F' THEN 'Female'
	WHEN ci.cst_gnder = 'n/a' AND ci_birth.gen = 'M' THEN 'Male'
	ELSE COALESCE(ci.cst_gnder,'n/a')
END AS gender,
ci_birth.bdate AS birthdate,
ci.cst_material_status AS marital_status,
ci_loc.cntry AS country,
ci.cst_create_date AS create_date
FROM silver.crm_cust_info AS ci
LEFT JOIN silver.erp_cust_az12 AS ci_birth
ON ci.cst_key = ci_birth.cid
LEFT JOIN silver.erp_loc_a101 AS ci_loc
ON ci.cst_key = ci_loc.cid