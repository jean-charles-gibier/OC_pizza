SELECT * FROM mydb.employee_has_role;
/*
0 row(s) affected, 1 warning(s): 1452 
Cannot add or update a child row: a foreign key constraint fails 
(`mydb`.`employee_has_role`, CONSTRAINT `fk_employee_has_role_role1`
 FOREIGN KEY (`role_id_role`) REFERENCES `role` (`id_role`))

*/
INSERT IGNORE INTO employee_has_role (
    employee_id_employee,
    role_id_role,
    start_date
) VALUES (
    1,
    1,
    now()
)
;
     INSERT IGNORE INTO role(
    id_role,
    id_parent,
    `name`,
    `level`
    
    ) VALUES (
    1,
    1,
    'BASIC',
    0
    )

;
select * from role;
    INSERT IGNORE INTO role(
    id_role,
    id_parent,
    libelle
    ) VALUES (
    1,
    1,
    'BASIC'
    )
;


desc menu_item;

/*
INSERT IGNORE INTO `ingredient`
(
`name`,
`id_unity`,
`value`,
`unit_price`,
`minimum_limit`)
VALUES
(
<{name: }>,
<{id_unity: }>,
<{value: }>,
<{unit_price: }>,
<{minimum_limit: }>);

1	kilogramme	Kg
2	gramme	G
3	liter	L
4	mililiter	Ml
5	unit	.
		

{
'name': 'pizza dough extra',
'id_unity': 1,
'value': 1,
'unit_price': 2.5,
'minimum_limit': 100 
},
{
'name': 'pizza dough std',
'id_unity': 1,
'value': 1,
'unit_price': 2.1,
'minimum_limit': 200 
},
{
'name': 'extra-virgin olive oil',
'id_unity': 3,
'value': 1,
'unit_price': 2.5,
'minimum_limit': 50 
},
{
'name': 'Frank’s hot sauce',
'id_unity': 4,
'value': 200,
'unit_price': 2.4,
'minimum_limit': 2000 
},
{
'name': 'bulk butter',
'id_unity': 1,
'value': 20,
'unit_price': 4.4,
'minimum_limit': 20 
},
{
'name': 'chicken legs',
'id_unity': 5,
'value': 100,
'unit_price': 45.6,
'minimum_limit': 10 
},
{
'name': 'whole-milk plain yogurt',
'id_unity': 1,
'value': 1,
'unit_price': 5.0,
'minimum_limit': 2 
},
{
'name': 'lemon juice',
'id_unity': 3,
'value': 1,
'unit_price': 3.2,
'minimum_limit': 2 
},
{
'name': 'garlic powder',
'id_unity': 2,
'value': 1000,
'unit_price': 5.2,
'minimum_limit': 1000 
},
{
'name': 'mild blue cheese',
'id_unity': 1,
'value': 1,
'unit_price': 6.2,
'minimum_limit': 5 
},
{
'name': 'mozzarella cheese',
'id_unity': 1,
'value': 1,
'unit_price': 5.2,
'minimum_limit': 5 
},
{
'name': 'parmesan cheese',
'id_unity': 1,
'value': 1,
'unit_price': 4,
'minimum_limit': 5 
},
{
'name': 'gruyere cheese',
'id_unity': 1,
'value': 1,
'unit_price': 4.4,
'minimum_limit': 5 
},
{
'name': 'gruyere cheese',
'id_unity': 1,
'value': 1,
'unit_price': 4.4,
'minimum_limit': 5 
},


{
'name': 'tomato sauce',
'id_unity': 1,
'value': 1,
'unit_price': 3.3,
'minimum_limit': 5 
},
{
'name': 'tomato sauce',
'id_unity': 3,
'value': 1,
'unit_price': 2.1,
'minimum_limit': 5 
},
{
'name': 'salt',
'id_unity': 2,
'value': 1000,
'unit_price': 2,
'minimum_limit': 2000 
},
{
'name': 'pepper',
'id_unity': 2,
'value': 1000,
'unit_price': 3,
'minimum_limit': 2000 
},
{
'name': 'salmon slices',
'id_unity': 1,
'value': 1,
'unit_price': 5,
'minimum_limit': 3 
},
{
'name': 'fresh egg',
'id_unity': 5,
'value': 1,
'unit_price': 0.5,
'minimum_limit': 40 
},
{
'name': 'mushrooms',
'id_unity': 1,
'value': 1,
'unit_price': 2.5,
'minimum_limit': 4 
},
{
'name': 'ham',
'id_unity': 1,
'value': 1,
'unit_price': 3.4,
'minimum_limit': 5 
},
{
'name': 'ham',
'id_unity': 1,
'value': 1,
'unit_price': 4.1,
'minimum_limit': 2 
},
{
'name': 'Pepperoni',
'id_unity': 1,
'value': 1,
'unit_price': 3.1,
'minimum_limit': 4 
}

*/
