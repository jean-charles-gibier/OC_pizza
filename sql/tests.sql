
-- order 
select * from `order`;

-- prix de fabrication d'une commande N°x
select DESIGNATION, concat( TRIM(TRAILING 0 from TOTAL),  ' €') AS TOTAL
from (
	SELECT DESIGNATION, TOTAL from (
	SELECT  max('TOTAL commande') AS DESIGNATION,
	sum( rhi.quantity * (i.unit_price / i.value_unit)) AS TOTAL
	--   rhi.quantity * i.unit_price 
		FROM order_has_menu_item hmi
		inner join recipe r  on hmi.menu_item_id_menu_item = r.menu_item_id_menu_item
		inner join recipe_has_ingredient rhi on r.id_recipe =rhi.recipe_id_recipe 
		inner join ingredient i on i.id_ingredient = rhi.ingredient_id_ingredient 
		inner join unit u on u.id_unit = i.id_unit
		where hmi.order_id_order  = 15
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
/*
La première: retrouver sur une commande qui est commanditaire, qui est le pizzaiolo, qui est le livreur
La deuxième: combien reste t-il de tel ingredient dans tel stock
Le dernière, retrouver le prix total d'une commande qui contient plusieurs pizzas differentes
*/

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
    s.value_stock ,
    i.minimum_limit ,
    case when s.value_stock >= i.minimum_limit then 'OK' else 'RUPTURE' end AS stock
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

-- Indique si une pizza donnée est réalisable avec stock pour un restau donné.
-- paramètre pizzeria X  plat Y  par exemple
select 
c.id_menu_item id_menu,
mi2.`description`,
c.id_pizzeria id_pizzeria,
p2.`name`,
 min(
c.ingredient_ok
  ) 
is_dispo 
 from ( 
	select 0 as zero,
	b.id_pizzeria as id_pizzeria,
	a.menu_item_id_menu_item as id_menu_item,
	a.quantity < b.value_stock as ingredient_ok  
    from (
--   ingrédients nécessaires a la prepartion du menu_item    
		select rhi.ingredient_id_ingredient, 
        rhi.quantity,
		r.menu_item_id_menu_item 
		from menu_item mi 
		inner join recipe r on r.menu_item_id_menu_item = mi.id_menu_item
		inner join recipe_has_ingredient rhi on rhi.recipe_id_recipe = r.id_recipe
	)a inner join (
--  etat des ingrédients pour tout les restos
		select si.ingredient_id_ingredient, si.value_stock, p.id_pizzeria 
		from pizzeria p 
		inner join stock_ingredient si on p.id_pizzeria = si.pizzeria_id_pizzeria
		where si.date_change = (
			select max(date_change) from stock_ingredient dc where
			dc.ingredient_id_ingredient = si.ingredient_id_ingredient
			and dc.pizzeria_id_pizzeria  = si.pizzeria_id_pizzeria 
			)
	) b on b.ingredient_id_ingredient = a.ingredient_id_ingredient
)c 
inner join pizzeria p2 on c.id_pizzeria = p2.id_pizzeria
inner join menu_item mi2 on c.id_menu_item = mi2.id_menu_item
group by 1,3
order by 5
;

select * from stock_ingredient order by 2 desc;

-- de quoi est constituée la pizza X 2
select * from menu_item mi 
inner join recipe r on r.menu_item_id_menu_item = mi.id_menu_item
 inner join recipe_has_ingredient rhi on r.id_recipe = rhi.recipe_id_recipe
 inner join ingredient i on rhi.ingredient_id_ingredient = i.id_ingredient
 where mi.id_menu_item = 2;
 
 -- on va virer l'ingredient 4 du resto 1 