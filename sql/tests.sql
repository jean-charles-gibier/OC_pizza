
-- [1] liste des commandes générales 
select * from `order`;

-- [2] prix de fabrication d'une commande N°x
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



-- [3] Select addresse de livraison de la commande # pizzeria from # order 
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

-- [4] Détail du contenu de la livraison + etat de la commande order #
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
            
# [5] select historique d'un ingredient en fct d'un pizzeria x et d'un ingredient y
select * from stock_ingredient 
where pizzeria_id_pizzeria = 3 and ingredient_id_ingredient = 2
order by date_change desc;


# [6] visualisation des stock en cours par pizzeria et par ingredient
# avec rupture et unités de stockage
select 
	s.ingredient_id_ingredient,
	s.pizzeria_id_pizzeria , i.name, p.name,
	s.date_change ,
    u.label,
    s.value_stock ,
    i.minimum_limit ,
    case when s.value_stock >= i.minimum_limit then 'OK' else 'RUPTURE' end AS stock
from   stock_ingredient s
inner join pizzeria p on s.pizzeria_id_pizzeria = p.id_pizzeria
inner join ingredient i on s.ingredient_id_ingredient = i.id_ingredient
inner join unit u on i.id_unit = u.id_unit
    where s.date_change = (
		select max(date_change) from stock_ingredient dc where
        dc.ingredient_id_ingredient = s.ingredient_id_ingredient
        and dc.pizzeria_id_pizzeria  = s.pizzeria_id_pizzeria 
        )
--     group by s.ingredient_id_ingredient, s.pizzeria_id_pizzeria 
	;

-- [7] Indique si une pizza donnée est réalisable avec stock pour un restau donné.
-- paramètre pizzeria X  plat Y  par exemple
select 
c.id_menu_item id_menu,
mi2.`description`,
c.id_pizzeria id_pizzeria,
p2.`name`,
 min(
c.ingredient_ok
  ) 
REALISABLE 
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

-- [8] de quoi est constituée la pizza X (ici 2)
select i.* from menu_item mi 
inner join recipe r on r.menu_item_id_menu_item = mi.id_menu_item
 inner join recipe_has_ingredient rhi on r.id_recipe = rhi.recipe_id_recipe
 inner join ingredient i on rhi.ingredient_id_ingredient = i.id_ingredient
 where mi.id_menu_item = 2;
 
 -- virer l'ingredient 4 du resto 1 et retester
 -- checker un stock pour un restau 
select * from stock_ingredient order by date_change desc;
--  checker la présence de cet ingrédient dans une recette en [8] 
 -- et retester le test  [7] pour voir que la réalisation n'est plus disponible
 
 
 -- [9] toutes les ingrédients de toutes les commandes
 select * FROM order_has_menu_item hmi
inner join recipe r  on hmi.menu_item_id_menu_item = r.menu_item_id_menu_item
inner join recipe_has_ingredient rhi on r.id_recipe =rhi.recipe_id_recipe 
inner join ingredient i on i.id_ingredient = rhi.ingredient_id_ingredient 
inner join unit u on u.id_unit = i.id_unit

-- where hmi.order_id_order  >= 1
order by 1;

-- tests standards
-- ma commande peut-elle contenir plusieurs pizzas? OUI
select o.id_order, 
count(o.id_order) as `nb plats`, 
group_concat( mi.description SEPARATOR ' | ' ) as contenu   
from `order` o
inner join order_has_menu_item ohmi on o.id_order = ohmi.order_id_order
inner join menu_item mi on ohmi.menu_item_id_menu_item = mi.id_menu_item
group by  o.id_order;


-- puis-je retrouver le contenu d'une commande? OUI
-- cf ci dessus (par le nuléro d'une commande)

-- puis-je afficher les commandes en attente dans un resto particulier? OUI

select o.id_order,
o.hist_id_pizzeria, 
count(o.id_order) as `nb plats`, 
s.label,
group_concat( mi.description SEPARATOR ' | ' ) as contenu   
from `order` o
inner join order_has_menu_item ohmi on o.id_order = ohmi.order_id_order
inner join menu_item mi on ohmi.menu_item_id_menu_item = mi.id_menu_item
inner join order_has_person ohp on ohp.order_id_order = o.id_order
inner join statut s on ohp.statut_id_statut = s.id_statut
where ohp.statut_id_statut >= (select id_statut from statut where label like 'to prepare')
group by  o.id_order
order by 1;

-- puis-je afficher les commandes en attente d'un client? 

select 
s.label,
p.first_name, p.last_name,
ohp.order_id_order,
mi.description, mi.unit_price

from person p
inner join order_has_person ohp on  ohp.person_id_person = p.id_person
	and ohp.statut_id_statut  = (select max(statut_id_statut) from order_has_person where ohp.order_id_order = order_id_order)
inner join statut s on ohp.statut_id_statut = s.id_statut
inner join order_has_menu_item ohmi on ohmi.order_id_order = ohp.order_id_order 
inner join menu_item mi on mi.id_menu_item = ohmi.menu_item_id_menu_item
 ; 

-- puis-je afficher l'adresse de livraison d'une commande terminée même après que le client a changé son adresse?
-- NON on garde les adresses multiples (pour un choix possible lors de la prise de commande) mais les lieux de livraison ne sont pas historisés

-- puis retrouver le prix payé pour une pizza dans une commande terminé même si le prix a changé depuis?
-- seulement le prix total est historisé, il faudrait ajouter une cpie du prix sur order_has_menu_item

-- puis-je lister les pizzas pour lesquelles tous les ingrédients sont en stock?
-- OUI cf plus haut 

 