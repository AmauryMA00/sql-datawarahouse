CREATE VIEW gold.dim_products AS 
SELECT 
ROW_NUMBER() OVER(ORDER BY prd_info.prd_start_dt, prd_info.prd_key ) AS product_key,
prd_info.prd_id AS product_id, 
prd_info.prd_key AS product_number,
prd_info.prd_nm AS product_name,
prd_info.cat_id AS product_category_id,
COALESCE(erp_prd.cat,'Components') AS product_category,
COALESCE(erp_prd.subcat,'Pedals') AS product_subcategory,
COALESCE(erp_prd.maintenance,'Yes')AS product_maintenance,
prd_info.prd_cost AS product_cost,
prd_info.prd_line AS product_line,
prd_info.prd_start_dt AS product_start_date
FROM silver.crm_prd_info AS prd_info
LEFT JOIN silver.erp_px_cat_g1v2 AS erp_prd
ON prd_info.cat_id = erp_prd.id
WHERE prd_end_dt IS NULL