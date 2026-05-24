-- 1. Remove Leading and Trailing spaces
SELECT shipment_id,  
	proper_case(trim(origin_warehouse)) as origin_warehouse, 
	proper_case(trim(destination_city)) as destination_city,
	ucase(trim(destination_state)) as destination_state,
	proper_case(trim(carrier)) as carrier,
	proper_case(trim(shipment_status)) as shipment_status, 
    
-- 2. Convert ship_date and delivery_date from STR to Date
	str_to_date(delivery_date, '%Y-%m-%d') as delivery_date ,
	str_to_date(ship_date, '%Y-%m-%d') as ship_date,

-- 3. Compute the Diferrence between ship_date and delivery_date
	datediff(ship_date,delivery_date) as transit_days, 
    CASE 
		WHEN(delivery_date) < (ship_date) THEN 'Invalid'
        WHEN(delivery_date) = (ship_date) THEN 'Same Day Delivery'
        ELSE 'Valid'
    END as transit_status,
    
-- 4. Validate weight_kg
	CASE 
		WHEN (weight_kg) < 0 THEN abs(weight_kg) 
        WHEN (weight_kg) = 0 THEN 0
        ELSE weight_kg
    END as valid_weight,
    
-- 5. Check for Duplicates 
row_number() over(partition by origin_warehouse, destination_city,  destination_state, carrier, ship_date, convert(weight_kg, char), convert(freight_cost, char)
order by shipment_id) as row_num
FROM shipment_tbl;

-- 6. Remove Duplicates 
DELETE FROM shipment_tbl 
	WHERE shipment_id IN (
	SELECT shipment_id FROM( 
	SELECT shipment_id, row_number() over (partition by 
	origin_warehouse, 
	destination_city, 
	carrier, 
	ship_date 
	ORDER BY shipment_id) AS row_num
FROM shipment_tbl) AS sub WHERE row_num > 1);
