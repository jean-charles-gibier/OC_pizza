
-- order 
select * from `order`;


-- prix de fabrication d'une commande N°x
select DESIGNATION, concat( TRIM(TRAILING 0 from TOTAL),  ' €') AS TOTAL
from (
	SELECT DESIGNATION, TOTAL from (
	SELECT  max('TOTAL commande')
	AS DESIGNATION,
	sum( rhi.quantity * (i.unit_price / i.value_unit)) AS TOTAL
	--   rhi.quantity * i.unit_price 
		FROM order_has_menu_item hmi
		inner join recipe r  on hmi.menu_item_id_menu_item = r.menu_item_id_menu_item
		inner join recipe_has_ingredient rhi on r.id_recipe =rhi.recipe_id_recipe 
		inner join ingredient i on i.id_ingredient = rhi.ingredient_id_ingredient 
		inner join unit u on u.id_unit = i.id_unit
		where hmi.order_id_order  = 2
		group  by hmi.order_id_order
		)a
union 
	SELECT DESIGNATION, TOTAL from (
    SELECT  
    concat(rhi.quantity, ' ',u.short_label , ' de ', i.name, ' a ', i.unit_price , ' € les ', i.value_unit,' ',u.short_label)
	AS DESIGNATION,
	rhi.quantity * (i.unit_price / i.value_unit) AS TOTAL
	--   rhi.quantity * i.unit_price 
	FROM order_has_menu_item hmi
	inner join recipe r  on hmi.menu_item_id_menu_item = r.menu_item_id_menu_item
	inner join recipe_has_ingredient rhi on r.id_recipe =rhi.recipe_id_recipe 
	inner join ingredient i on i.id_ingredient = rhi.ingredient_id_ingredient 
	inner join unit u on u.id_unit = i.id_unit
	where hmi.order_id_order  = 15
	order by 1
    )b
) c;



-- Select addresse de livraison de la commande # pizzeria from # order 
SELECT ahp.pizzeria_id_pizzeria, p.first_name, p.last_name, a.street_num, a.street, a.zip_code, a.city FROM address_has_pizzeria ahp 
            inner join address a on ahp.address_id_address = a.id_address and ahp.order = 1 and a.is_current = 1
            inner join person p on a.person_id_person = p.id_person and a.is_current = 1
			inner join order_has_person ohp on ohp.person_id_person = a.person_id_person
            where ohp.order_id_order = 15 
            and ohp.statut_id_statut = 5
            ;
            
select * from order_has_person where  order_id_order = 15 
-- and statut_id_statut = 5
;
select * from order_has_menu_item o where o.order_id_order >= 1 ;
select * from order_has_menu_item o where o.order_id_order = 2 ;

select * from statut ;


-- Select contenu de la livraison + etat de la commande order #
SELECT 
*
-- ohp.order_id_order, mi.description, ohmi.quantity, s.label 
 from  order_has_menu_item ohmi
			inner join menu_item mi on ohmi.menu_item_id_menu_item = mi.id_menu_item
            inner join order_has_person ohp on ohp.order_id_order = ohmi.order_id_order
            inner join statut s on s.id_statut = ohp.statut_id_statut
            where ohmi.order_id_order = 15  and (ohp.ts_change, ohp.statut_id_statut) = 
            ( select ts_change, statut_id_statut from  order_has_person
				where order_id_order = 15 order by ts_change, statut_id_statut desc limit 1) 
            ;
select * from  order_has_menu_item ohmi where ohmi.order_id_order = 15; 
            
# select historique d'un ingredient
select * from stock_ingredient 
where pizzeria_id_pizzeria = 3 and ingredient_id_ingredient = 2
order by date_change desc;


# visualisation des stock en cours par pizzeria et par ingredient
select 
	s.ingredient_id_ingredient,
	s.pizzeria_id_pizzeria , i.name, p.name,
	s.date_change ,
    s.value_stock
from   stock_ingredient s
inner join pizzeria p on s.pizzeria_id_pizzeria = p.id_pizzeria
inner join ingredient i on s.ingredient_id_ingredient = i.id_ingredient
    where s.date_change = (
		select max(date_change) from stock_ingredient dc where
        dc.ingredient_id_ingredient = s.ingredient_id_ingredient
        and dc.pizzeria_id_pizzeria  = s.pizzeria_id_pizzeria 
        )
--     group by s.ingredient_id_ingredient, s.pizzeria_id_pizzeria 
	;




