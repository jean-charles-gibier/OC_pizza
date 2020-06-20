SELECT CEIL(RAND()*2);
truncate recipe_has_ingredient;
insert ignore into recipe_has_ingredient
select id_recipe as recipe_id_recipe , 
(SELECT id_ingredient FROM ingredient where name like '%dough%' ORDER BY RAND() LIMIT 1) as ingredient_id_ingredient,
(1.1 + RAND())/3.0 as quantity
from recipe;


insert ignore into recipe_has_ingredient
select id_recipe as recipe_id_recipe , 
(SELECT id_ingredient FROM ingredient where name like '%dough%' ORDER BY RAND() LIMIT 1) as ingredient_id_ingredient,
(1.1 + RAND())/3.0 as quantity
from recipe;

select recipe_id_recipe, ingredient_id_ingredient from recipe_has_ingredient;
-- insert recipe_has_ingredient
select 1, 
id_ingredient,
minimum_limit / (100.0 *RAND())
from 
(select id_ingredient, minimum_limit from ingredient where name not like '%dough%' ORDER BY RAND() LIMIT 5) a
--  where (a.id_recipe, b.id_ingredient) not in (select recipe_id_recipe, ingredient_id_ingredient from recipe_has_ingredient)
 ;



select * from recipe_has_ingredient;
desc recipe_has_ingredient;
/*


*/