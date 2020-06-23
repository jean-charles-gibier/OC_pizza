
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
	where hmi.order_id_order  = 2
	order by 1
    )b
) c;



-- Select addresse de livraison de la commande # pizzeria from # order 
SELECT p.first_name, p.last_name, a.street_num, a.street, a.zip_code, a.city FROM address_has_pizzeria ahp 
            inner join address a on ahp.address_id_address = a.id_address and ahp.order = 1 and a.is_current = 1
            inner join person p on a.person_id_person = p.id_person and a.is_current = 1
			inner join order_has_person ohp on ohp.person_id_person = a.person_id_person
            where ohp.order_id_order = 1 and ohp.statut_id_statut = 5;
       select * from order_has_person where  order_id_order = 1
       and statut_id_statut = 5;

-- Select contenu de la livraison + etat de la livraison order #
SELECT ohp.order_id_order, mi.description, ohmi.quantity, s.label  from  order_has_menu_item ohmi
			inner join menu_item mi on ohmi.menu_item_id_menu_item = mi.id_menu_item
            inner join order_has_person ohp on ohp.order_id_order = ohmi.order_id_order
            inner join statut s on s.id_statut = ohp.statut_id_statut
            where ohmi.order_id_order = 1  and (ohp.ts_change, ohp.statut_id_statut) = 
            ( select ts_change, statut_id_statut from  order_has_person
				where order_id_order = 1 order by ts_change, statut_id_statut desc limit 1) 
            ;

            
# select historique d'un ingredient
select * from stock_ingredient 
where pizzeria_id_pizzeria = 3 and ingredient_id_ingredient = 2
order by date_change desc;

#  décrementation des stocks => validation de toutes les commandes 'To prepare'
 insert into stock_ingredient (ingredient_id_ingredient, date_change, value_stock, pizzeria_id_pizzeria)
select 
	s.ingredient_id_ingredient , 
	DATE_ADD(NOW(), INTERVAL 1 HOUR),
    s.value_stock - a.quantity,
    s.pizzeria_id_pizzeria
from   stock_ingredient s
inner join (
	SELECT o.hist_id_pizzeria, rhi.ingredient_id_ingredient, rhi.quantity from `order` o 
	inner join order_has_person ohp on ohp.order_id_order = o.id_order
	inner join order_has_menu_item ohm on ohm.order_id_order = o.id_order
	inner join recipe r on ohm.menu_item_id_menu_item = r.menu_item_id_menu_item
	inner join recipe_has_ingredient rhi on r.id_recipe =rhi.recipe_id_recipe 
	inner join ingredient i on i.id_ingredient = rhi.ingredient_id_ingredient 
	inner join unit u on u.id_unit = i.id_unit
	where statut_id_statut = (select id_statut from statut where label like 'To prepare') 
	) a
    on  a.hist_id_pizzeria = s.pizzeria_id_pizzeria 
    and a.ingredient_id_ingredient = s.ingredient_id_ingredient
    and s.date_change = (
		select max(date_change) from stock_ingredient dc where
        dc.ingredient_id_ingredient = s.ingredient_id_ingredient
        and dc.pizzeria_id_pizzeria  = s.pizzeria_id_pizzeria 
        )
    group by s.ingredient_id_ingredient, s.pizzeria_id_pizzeria 
	;

# visualisation des stock en cours par prizzeria et ingredient
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




