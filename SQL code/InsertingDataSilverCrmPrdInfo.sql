INSERT INTo silver.crm_prd_info (
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
