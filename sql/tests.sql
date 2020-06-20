
-- prix de fabrication d'une commande
SELECT  concat(rhi.quantity, ' ',u.short_label , ' de ', i.name, ' a ', i.unit_price , '€ les ', i.value_unity,' ',u.short_label)
AS DESIGNATION,
concat('Total :', rhi.quantity * (i.unit_price / i.value_unity),  '€') AS TOTAL
--   rhi.quantity * i.unit_price 
FROM order_has_menu_item hmi
inner join recipe r  on hmi.menu_item_id_menu_item = r.menu_item_id_menu_item
inner join recipe_has_ingredient rhi on r.id_recipe =rhi.recipe_id_recipe 
inner join ingredient i on i.id_ingredient = rhi.ingredient_id_ingredient 
inner join unity u on u.id_unity = i.id_unity
where hmi.order_id_order  = 2
order by 1;



-- Select # pizzeria from # order 
SELECT pizzeria_id_pizzeria FROM address_has_pizzeria ahp 
            inner join address a on ahp.address_id_address = a.id_address and ahp.order = 1 and a.is_current = 1
            where a.person_id_person = 1;
            
# select historique d'un ingredient
select * from stock_ingredient 
where pizzeria_id_pizzeria = 3 and ingredient_id_ingredient = 2
order by date_change desc;

#  décrementation des stocks => validation de toutes les commandes 'To prepare'

 insert into stock_ingredient (ingredient_id_ingredient, date_change, value_stock, pizzeria_id_pizzeria)
select 
	s.ingredient_id_ingredient , 
	now(),
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
	inner join unity u on u.id_unity = i.id_unity
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



select * from stock_ingredient
order by 1;


insert into stock_ingredient
select 
	1, 
	now(),
    99,
    1 from dual;
    
    
    
    
    
    
    
    
    ;
    
    
    
select now() + 10000
;