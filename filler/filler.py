"""
usage :
filler.py [ORDERS_ONLY]
fills all tables of schema OC Pizza with coherent test cases
If parameter "ORDERS_ONLY" is set, the filler will play only
the ordering part of the users stories.
"""
import subprocess
import sys
import random
from faker import Faker
import mysql.connector

DB_USERNAME = "<YOURUSERNAME>"
DB_PASSWORD = "<YOURPASSWD>"
DB_NAME = "<YOURDBNAME>"
DB_HOST = "<YOURHOST>"  

# we need these externals infos to cleanup quickly our db
# DB_USERNAME / DB_PASSWORD will be used for authentication
PATH_MYSQL = "c:/Program Files/MySQL/MySQL Server 8.0/bin/mysql.exe"
SQLCLEAN_DB = "D:/work/source/repos/OC_pizza/sql/truncate_all.sql"

# nb items
NB_PERSONS = 100
NB_PIZZERIAS = 10
NB_EMPLOYEES = NB_PIZZERIAS * 6
NB_ORDERS = 15

FAKE_FRANCAIS = Faker("fr_FR")
FAKE_ITALIANO = Faker("it_IT")


def get_db():
    """
    set cnx with database
    :return: handle connector
    """
    return mysql.connector.connect(
        **{
            "user": DB_USERNAME,
            "password": DB_PASSWORD,
            "host": DB_HOST,
            "port": 3306,
            "database": DB_NAME,
        }
    )


def make_persons(nb_persons):
    """
    make_persons generate person items
    :param nb_persons: nb to generate
    :return: list
    """
    fake_persons = [
        {
            "nick_name": "FAKE_OWNER",
            "first_name": "FAKE_FIRST_NAME",
            "last_name": "FAKE_LAST_NAME",
            "phone_number": "01 23 45 67 89",
            "email": "fake@email.com",
            "password": "",
        }
    ]

    for _ in range(1, nb_persons):
        last_name = FAKE_FRANCAIS.last_name()
        first_name = FAKE_FRANCAIS.first_name()
        nick_name = last_name[0:4] + "_" + str(random.randrange(9999))
        phone_number = "06" + " {:02d} {:02d} {:02d} {:02d}".format(
            random.randrange(99),
            random.randrange(99),
            random.randrange(99),
            random.randrange(99),
        )
        email = first_name + "." + last_name + "@" + FAKE_FRANCAIS.domain_name(levels=1)

        fake_persons.append(
            {
                "nick_name": nick_name,
                "first_name": first_name,
                "last_name": last_name,
                "phone_number": phone_number,
                "email": email,
                "password": "",
            }
        )
    return fake_persons


def make_an_address(id_person):
    """
    make_an_address make address items one for each person
    :param id_person:
    :return: list
    """
    return {
        "num_address": "0",
        "person_id_person": str(id_person),
        "is_current": 1,
        "street_num": random.randint(1, 200),
        "street": FAKE_FRANCAIS.street_name(),
        "city": FAKE_FRANCAIS.city(),
        "zip_code": f"{random.randint(1000, 99000):05}",
        "country": "France",
        "localization": "ASK_GG",
    }


def make_an_pizzeria_address(actual_list):
    """
    create pizzeria items
    :param actual_list: list for doublon checking
    :return: new list
    """
    city = str(FAKE_FRANCAIS.city())
    street = str(FAKE_FRANCAIS.street_name())
    rand_name = random.choice([city, street])
    is_vowel = str(rand_name).upper().startswith(("A", "E", "I", "O", "U", "Y"))
    article = (
        "du "
        if (rand_name.upper().startswith(("CHEMIN", "PASSAGE", "BOULEVARD")))
        else (
            "de la "
            if rand_name.upper().startswith("RUE")
            else (
                "de l'"
                if rand_name.upper().startswith("AVENUE")
                else ("d'" if is_vowel is True else "de ")
            )
        )
    )
    while True:
        to_test = {
            "name": random.choice(["Restaurant ", "Pizzeria ", "OC Pizza "])
                    + article + rand_name,
            "address": str(random.randint(1, 200)) + ", " + street,
            "city": city,
            "zip_code": f"{random.randint(1000, 99000):05}",
            "country": "France",
            "localization": "ASK_GG",
        }

        if to_test not in actual_list:
            break
    return to_test


def make_employees(nb_employees, param_pk_pizzeria):
    """
    # generate employee
    """
    fake_employees = list()
    count_for_each = dict()
    entitlement = ["MANAGER", "COOK", "CASHIER", "DELIVERER", "WAITER"]

    for _ in range(1, nb_employees):
        last_name = FAKE_ITALIANO.last_name()
        first_name = FAKE_ITALIANO.first_name()
        random_pizzeria = random.choice(param_pk_pizzeria)
        count_for_each[random_pizzeria] = (
            0
            if random_pizzeria not in count_for_each
            else count_for_each[random_pizzeria] + 1
        )
        num_registration = (
                str(random_pizzeria) + "-" + str(count_for_each[random_pizzeria] + 1)
        )
        phone_number = "06" + " {:02d} {:02d} {:02d} {:02d}".format(
            random.randrange(99),
            random.randrange(99),
            random.randrange(99),
            random.randrange(99),
        )
        email = first_name + "." + last_name + "@" + FAKE_FRANCAIS.domain_name(levels=1)

        fake_employees.append(
            {
                "pizzeria_id_pizzeria": str(random_pizzeria),
                "num_registration": num_registration,
                "first_name": first_name,
                "last_name": last_name,
                "entitlement": entitlement[min(count_for_each[random_pizzeria], 4)],
                "hire_date": "2020-06-16",
                "password": "TOFILL",
                "email": email,
                "phone_number": phone_number,
            }
        )
    return fake_employees


def make_menu_items(id_category):
    """
    id_category : default id for category
    """
    local_menu_items = [
        {
            "category_id_category": id_category,
            "description": "Ricky’s Automatic Extra Cheese",
            "unit_price": 17.5,
            "picture": "default.png",
            "preparation_time": 15,
        },
        {
            "category_id_category": id_category,
            "description": "Christian Science Pizza Room",
            "unit_price": 20.5,
            "picture": "default.png",
            "preparation_time": 12,
        },
        {
            "category_id_category": id_category,
            "description": "Burritos As Big As Your Head Pizza",
            "unit_price": 17.5,
            "picture": "default.png",
            "preparation_time": 15,
        },
        {
            "category_id_category": id_category,
            "description": "Airplane Pizza",
            "unit_price": 15.0,
            "picture": "default.png",
            "preparation_time": 10,
        },
        {
            "category_id_category": id_category,
            "description": "Yumi Yumi Pepperoni",
            "unit_price": 16.0,
            "picture": "default.png",
            "preparation_time": 15,
        },
        {
            "category_id_category": id_category,
            "description": "Pizzageddon",
            "unit_price": 16.0,
            "picture": "default.png",
            "preparation_time": 15,
        },
        {
            "category_id_category": id_category,
            "description": "The Mozzarella Fellas",
            "unit_price": 17.0,
            "picture": "default.png",
            "preparation_time": 15,
        },
        {
            "category_id_category": id_category,
            "description": "Not Cheeseburgers Pizza",
            "unit_price": 15.5,
            "picture": "default.png",
            "preparation_time": 12,
        },
        {
            "category_id_category": id_category,
            "description": "Mission: Impizzable",
            "unit_price": 17.5,
            "picture": "default.png",
            "preparation_time": 15,
        },
        {
            "category_id_category": id_category,
            "description": "Doctor Spock’s Quiet Baby Brick Oven Trattoria",
            "unit_price": 16.5,
            "picture": "default.png",
            "preparation_time": 12,
        },
        {
            "category_id_category": id_category,
            "description": "Pizza For Pyros",
            "unit_price": 17,
            "picture": "default.png",
            "preparation_time": 15,
        },
        {
            "category_id_category": id_category,
            "description": "The Da Vinci Crust",
            "unit_price": 16.5,
            "picture": "default.png",
            "preparation_time": 12,
        },
        {
            "category_id_category": id_category,
            "description": "Big Fat Italian Pizza",
            "unit_price": 20.5,
            "picture": "default.png",
            "preparation_time": 17,
        },
        {
            "category_id_category": id_category,
            "description": "Mormon Tabernacle Pizza Gazebo",
            "unit_price": 18.5,
            "picture": "default.png",
            "preparation_time": 15,
        },
        {
            "category_id_category": id_category,
            "description": "Now That’s What I Call Pizza!",
            "unit_price": 17.5,
            "picture": "default.png",
            "preparation_time": 15,
        },
        {
            "category_id_category": id_category,
            "description": "Chunky Donkey Pizza",
            "unit_price": 16.5,
            "picture": "default.png",
            "preparation_time": 13,
        },
        {
            "category_id_category": id_category,
            "description": "Crusty’s",
            "unit_price": 16,
            "picture": "default.png",
            "preparation_time": 12,
        },
        {
            "category_id_category": id_category,
            "description": "Mean Old Mr. Pizza",
            "unit_price": 17.5,
            "picture": "default.png",
            "preparation_time": 15,
        },
        {
            "category_id_category": id_category,
            "description": "Pups & Pies Great Pizza",
            "unit_price": 18,
            "picture": "default.png",
            "preparation_time": 15,
        },
        {
            "category_id_category": id_category,
            "description": "Onomotopizza",
            "unit_price": 20,
            "picture": "default.png",
            "preparation_time": 15,
        },
        {
            "category_id_category": id_category,
            "description": "Pizza’hoy!",
            "unit_price": 15.5,
            "picture": "default.png",
            "preparation_time": 12,
        },
        {
            "category_id_category": id_category,
            "description": "NY Style Pizzarium",
            "unit_price": 17,
            "picture": "default.png",
            "preparation_time": 14,
        },
        {
            "category_id_category": id_category,
            "description": "Ricky’s Automatic Extra Cheese",
            "unit_price": 17.5,
            "picture": "default.png",
            "preparation_time": 15,
        },
        {
            "category_id_category": id_category,
            "description": "The Horse With No Pizza",
            "unit_price": 19,
            "picture": "default.png",
            "preparation_time": 16,
        },
        {
            "category_id_category": id_category,
            "description": "Mary Worth’s Pointless Pizza",
            "unit_price": 17,
            "picture": "default.png",
            "preparation_time": 14,
        },
        {
            "category_id_category": id_category,
            "description": "Raphael’s Famous Footlong Pizzas on Tenth",
            "unit_price": 17.5,
            "picture": "default.png",
            "preparation_time": 15,
        },
    ]
    return local_menu_items


def make_unities():
    """
    make default unities
    """
    unities = [
        {"label": "kilogramme", "short_label": "Kg"},
        {"label": "gramme", "short_label": "G"},
        {"label": "liter", "short_label": "L"},
        {"label": "mililiter", "short_label": "Ml"},
        {"label": "unit", "short_label": "."},
    ]

    return unities


def make_ingredients():
    """
    make default ingredients
    here id_unit is the litteral
     content of unit short label
    """
    local_ingredients = [
        {
            "name": "pizza dough extra",
            "id_unit": 'Kg',
            "value_unit": 1,
            "unit_price": 2.5,
            "minimum_limit": 100,
        },
        {
            "name": "pizza dough std",
            "id_unit": 'Kg',
            "value_unit": 1,
            "unit_price": 2.1,
            "minimum_limit": 200,
        },
        {
            "name": "extra-virgin olive oil",
            "id_unit": 'L',
            "value_unit": 1,
            "unit_price": 2.5,
            "minimum_limit": 50,
        },
        {
            "name": "Frank’s hot sauce",
            "id_unit": 'Ml',
            "value_unit": 200,
            "unit_price": 2.4,
            "minimum_limit": 2000,
        },
        {
            "name": "bulk butter",
            "id_unit": 'Kg',
            "value_unit": 2,
            "unit_price": 4.4,
            "minimum_limit": 20,
        },
        {
            "name": "chicken legs",
            "id_unit": '.',
            "value_unit": 100,
            "unit_price": 45.6,
            "minimum_limit": 10,
        },
        {
            "name": "whole-milk plain yogurt",
            "id_unit": 'G',
            "value_unit": 1,
            "unit_price": 5.0,
            "minimum_limit": 2,
        },
        {
            "name": "lemon juice",
            "id_unit": 'L',
            "value_unit": 1,
            "unit_price": 3.2,
            "minimum_limit": 2,
        },
        {
            "name": "garlic powder",
            "id_unit": 'G',
            "value_unit": 1000,
            "unit_price": 5.2,
            "minimum_limit": 1000,
        },
        {
            "name": "mild blue cheese",
            "id_unit": 'Kg',
            "value_unit": 1,
            "unit_price": 6.2,
            "minimum_limit": 5,
        },
        {
            "name": "mozzarella cheese",
            "id_unit": 'Kg',
            "value_unit": 1,
            "unit_price": 5.2,
            "minimum_limit": 5,
        },
        {
            "name": "parmesan cheese",
            "id_unit": 'Kg',
            "value_unit": 1,
            "unit_price": 4,
            "minimum_limit": 5,
        },
        {
            "name": "gruyere cheese",
            "id_unit": 'Kg',
            "value_unit": 1,
            "unit_price": 4.4,
            "minimum_limit": 5,
        },
        {
            "name": "White cheese",
            "id_unit": 'Kg',
            "value_unit": 1,
            "unit_price": 4.4,
            "minimum_limit": 5,
        },
        {
            "name": "tomato sauce",
            "id_unit": 'L',
            "value_unit": 1,
            "unit_price": 3.3,
            "minimum_limit": 5,
        },
        {
            "name": "rotten tomato sauce",
            "id_unit": 'L',
            "value_unit": 1,
            "unit_price": 2.1,
            "minimum_limit": 5,
        },
        {
            "name": "salt",
            "id_unit": 'G',
            "value_unit": 1000,
            "unit_price": 2,
            "minimum_limit": 2000,
        },
        {
            "name": "pepper",
            "id_unit": 'G',
            "value_unit": 1000,
            "unit_price": 3,
            "minimum_limit": 2000,
        },
        {
            "name": "salmon slices",
            "id_unit": 'Kg',
            "value_unit": 1,
            "unit_price": 5,
            "minimum_limit": 3,
        },
        {
            "name": "fresh egg",
            "id_unit": '.',
            "value_unit": 1,
            "unit_price": 0.5,
            "minimum_limit": 40,
        },
        {
            "name": "mushrooms",
            "id_unit": 'Kg',
            "value_unit": 1,
            "unit_price": 2.5,
            "minimum_limit": 4,
        },
        {
            "name": "ham",
            "id_unit": 'Kg',
            "value_unit": 1,
            "unit_price": 3.4,
            "minimum_limit": 5,
        },
        {
            "name": "prosciutto sliced",
            "id_unit": 'Kg',
            "value_unit": 1,
            "unit_price": 4.1,
            "minimum_limit": 2,
        },
        {
            "name": "Pepperoni",
            "id_unit": 'Kg',
            "value_unit": 1,
            "unit_price": 3.1,
            "minimum_limit": 4,
        },
    ]
    return local_ingredients


def make_status():
    """
    make default states
    """
    local_status = [
        {"label": "To select"},
        {"label": "To order"},
        {"label": "To pay"},
        {"label": "To prepare"},
        {"label": "To deliver"},
        {"label": "To confirm"},
        {"label": "Cancelled"},
    ]
    return local_status


def get_pk_list(param_db, table_name, pk_names):
    """
        get the list id of recorded
        """
    # list 2 return
    substitutes_list = list()

    local_cursor = param_db.cursor()
    local_cursor.execute(
        "select " + ",".join(pk_names) + "    from  {}".format(table_name)
    )

    for a_row in local_cursor:
        map_row = dict(zip(local_cursor.column_names, a_row))
        substitutes_list.append(map_row)

    # cursor.close()
    return substitutes_list


# -----------------------------------------------------------#
# --------------- Start of the filler program ---------------#
# -----------------------------------------------------------#

IS_ORDER_ONLY = "ORDERS_ONLY" in sys.argv

if not IS_ORDER_ONLY:
    # workaround 2 wipe our base quickly (if needed)
    wipe_command = [
        PATH_MYSQL,
        "-u" + DB_USERNAME,
        "-p" + DB_PASSWORD,
        "--database=" + DB_NAME,
    ]
    with open(SQLCLEAN_DB) as input_file:
        sql_exec = subprocess.Popen(
            wipe_command, stdin=input_file, stderr=subprocess.PIPE, stdout=subprocess.PIPE
        )
        output, error = sql_exec.communicate()

db = get_db()
cursor = db.cursor()

if not IS_ORDER_ONLY:
    # Affectation des 'statuts'
    statuts = make_status()
    current_query = """
    INSERT IGNORE INTO `statut` (
    `label`
    ) VALUES (
    %(label)s
    )
    """
    try:
        cursor.executemany(current_query, statuts)
    except mysql.connector.Error as err:
        print("Failed inserting database (21): {}".format(err))


    # populate table 'person' #####
    persons = make_persons(NB_PERSONS)
    current_query = """
    INSERT IGNORE INTO person (nick_name, first_name, last_name, phone_number, email) 
                    VALUES (%(nick_name)s,
                    %(first_name)s,
                    %(last_name)s,
                    %(phone_number)s,
                    %(email)s)
    """
    try:
        cursor.executemany(current_query, persons)
    except mysql.connector.Error as err:
        print("Failed inserting database  (6): {}".format(err))
    db.commit()

list_pk_person = [
    person["id_person"] for person in get_pk_list(db, "person", ("id_person",))
]

if not IS_ORDER_ONLY:
    # populate table 'address' #####
    addresses = list()
    for local_id in list_pk_person:
        addresses.append(make_an_address(local_id))

    current_query = """
    INSERT IGNORE INTO address (num_address, person_id_person,
            is_current, street_num,  street, city,
            zip_code, country, localization
            ) 
            VALUES (
            %(num_address)s,
            %(person_id_person)s,
            %(is_current)s,
            %(street_num)s,
            %(street)s,
            %(city)s,
            %(zip_code)s,
            %(country)s,
            %(localization)s
            )
    """
    try:
        cursor.executemany(current_query, addresses)
    except mysql.connector.Error as err:
        print("Failed inserting database  (7): {}".format(err))

list_pk_address = [
    person["id_address"] for person in get_pk_list(db, "address", ("id_address",))
]

if not IS_ORDER_ONLY:
    # populate table 'pizerria' #####
    addresses_pizzeria = list()
    for _ in range(NB_PIZZERIAS):
        addresses_pizzeria.append(make_an_pizzeria_address(addresses_pizzeria))

    current_query = """
        INSERT IGNORE INTO pizzeria
        (name, city, address,
        localization, zip_code, create_time)
        VALUES (
        %(name)s,
        %(city)s,
        %(address)s,
        %(localization)s,
        %(zip_code)s,
        CURRENT_TIMESTAMP);
    """

    try:
        cursor.executemany(current_query, addresses_pizzeria)
    except mysql.connector.Error as err:
        print("Failed inserting database (8): {}".format(err))

list_pk_pizzeria = [
    pizzeria["id_pizzeria"]
    for pizzeria in get_pk_list(db, "pizzeria", ("id_pizzeria",))
]

if not IS_ORDER_ONLY:
    # jointure 'pizerria / adresse'  #####
    # Note : les addresses des pizzerias ne correspondront pas aux localisations
    # des adresses client. Pour l'instant dans système de localisation la distribution
    # géographique se fait au hasard
    jointures_addresses_pizzeria = [
        dict(
            {
                "address_id_address": pk_address,
                "pizzeria_id_pizzeria": random.choice(list_pk_pizzeria),
            }
        )
        for pk_address in list_pk_address
    ]

    current_query = """
        INSERT IGNORE INTO address_has_pizzeria
        (address_id_address, pizzeria_id_pizzeria, 
        `order`)
        VALUES (%(address_id_address)s,
        %(pizzeria_id_pizzeria)s,
        1);
    """
    try:
        cursor.executemany(current_query, jointures_addresses_pizzeria)
    except mysql.connector.Error as err:
        print("Failed inserting database (9): {}".format(err))

    # populate table 'employee' #####
    # on garde list_pk_pizzeria

    employees = make_employees(NB_EMPLOYEES, list_pk_pizzeria)

    current_query = """
        INSERT IGNORE INTO employee (
        pizzeria_id_pizzeria, num_registration, first_name,
        last_name, entitlement, hire_date,
        password, email, phone_number, create_time
        )  VALUES (
            %(pizzeria_id_pizzeria)s,
            %(num_registration)s,
            %(first_name)s,
            %(last_name)s,
            %(entitlement)s,
            %(hire_date)s,
            %(password)s,
            %(email)s,
            %(phone_number)s,
            NOW()
            )
    """
    try:
        cursor.executemany(current_query, employees)
    except mysql.connector.Error as err:
        print("Failed inserting database (10): {}".format(err))

    # populate table 'role' #####
    # 1 seul role pour le moment
    # tout les employés seront branchés dessus
    current_query = """
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
    """
    try:
        cursor.execute(current_query)
    except mysql.connector.Error as err:
        print("Failed inserting database (11): {}".format(err))

list_pk_role = [role["id_role"] for role in get_pk_list(db, "role", ("id_role",))]
list_pk_employee = [
    employee["id_employee"]
    for employee in get_pk_list(db, "employee", ("id_employee",))
]

if not IS_ORDER_ONLY:

    jointures_role_employee = [
        dict({"employee_id_employee": pk_employee, "role_id_role": list_pk_role[0]})
        for pk_employee in list_pk_employee
    ]

    current_query = """
    INSERT IGNORE INTO employee_has_role (
        employee_id_employee,
        role_id_role,
        start_date
    ) VALUES (
        %(employee_id_employee)s,
        %(role_id_role)s,
        now()
    )
    """
    try:
        cursor.executemany(current_query, jointures_role_employee)
    except mysql.connector.Error as err:
        print("Failed inserting database (12): {}".format(err))

    # populate table 'category'
    # idem  1 seule catégorie pour le moment

    current_query = """
     INSERT IGNORE INTO `category`(
        `id_category`,
        `id_category_parent`,
        `libelle`
        ) VALUES (
        1,
        1,
        'BASIC'
        )
    """
    try:
        cursor.execute(current_query)
    except mysql.connector.Error as err:
        print("Failed inserting database (13): {}".format(err))

    # populate table 'menu'
    # idem  1 seul menu pour le moment

    current_query = """
    INSERT IGNORE INTO `menu`(
        `name`,
        `price`
    ) VALUES (
        'GENERIC',
        0
    )
    """
    try:
        cursor.execute(current_query)
    except mysql.connector.Error as err:
        print("Failed inserting database (14): {}".format(err))

list_pk_menu = [menu["id_menu"] for menu in get_pk_list(db, "menu", ("id_menu",))]

if not IS_ORDER_ONLY:
    # populate table 'unit'
    list_unities = make_unities()
    current_query = """
    INSERT IGNORE INTO `unit`
        (
            `label`,
            `short_label`
        ) VALUES (
            %(label)s,
            %(short_label)s
        )
    """
    try:
        cursor.executemany(current_query, list_unities)
    except mysql.connector.Error as err:
        print("Failed inserting database (15): {}".format(err))

# populate table 'menu_item'
list_pk_category = [
    role["id_category"] for role in get_pk_list(db, "category", ("id_category",))
]

menu_items = make_menu_items(list_pk_category[0])

if not IS_ORDER_ONLY:
    current_query = """
    INSERT IGNORE INTO menu_item(
        unit_price,
        preparation_time,
        picture,
        description,
        category_id_category
        ) VALUES (
        %(unit_price)s,
        %(preparation_time)s,
        %(picture)s,
        %(description)s,
        %(category_id_category)s
        )
    """
    try:
        cursor.executemany(current_query, menu_items)
    except mysql.connector.Error as err:
        print("Failed inserting database (16): {}".format(err))

list_pk_menu_item = [
    list_pk_menu_item["id_menu_item"]
    for list_pk_menu_item in get_pk_list(db, "menu_item", ("id_menu_item",))
]

if not IS_ORDER_ONLY:
    # populate table jointure 'menu_has_menu_item'
    # bind just one fake menu => doesnt matter for these tests case

    current_query = """
    INSERT IGNORE INTO `menu_has_menu_item` (
    `menu_id_menu`,
     `menu_item_id_menu_item`
     ) VALUES (
    %(menu_id_menu)s,
     %(menu_item_id_menu_item)s
     )
    """
    pseudo_join = []
    for i, a in enumerate(list_pk_menu_item):
        pseudo_join.append(
            {'menu_item_id_menu_item': a,
             'menu_id_menu': list_pk_menu[i % len(list_pk_menu)]
             }
        )
    try:
        cursor.executemany(current_query, pseudo_join)
    except mysql.connector.Error as err:
        print("Failed inserting database (99): {}".format(err))

    # populate table 'recipe'
    # ici on va faire une simple insertion "from select"
    # qui va reprendre les infos de menu_item en faisant
    # une pseudo recette pour chaque 'menu_item'

    current_query = """
    INSERT IGNORE INTO recipe (`menu_item_id_menu_item`,  `name`,
     `description`, `preparation_time`, `tl_procedure`)
    select 
    id_menu_item as `menu_item_id_menu_item`, 
    concat('Short: ', replace(reverse(description),' ', '') ) as `name`,
    concat('Recipe of: ', description) as `description`,
    FLOOR(RAND() * 60) as `preparation_time`,
    ' Sed ut perspiciatis, unde omnis iste natus error sit voluptatem 
    accusantium doloremque laudantium, totam rem aperiam eaque ipsa, quae
    ab illo inventore veritatis et quasi architecto beatae vitae dicta sunt,
    explicabo. Nemo enim ipsam voluptatem, quia voluptas sit, aspernatur aut
    odit aut fugit, sed quia consequuntur magni dolores eos, qui ratione
    voluptatem sequi nesciunt, neque porro quisquam est, qui dolorem ipsum'
    as `tl_procedure`
    from menu_item
    """
    try:
        cursor.execute(current_query)
    except mysql.connector.Error as err:
        print("Failed inserting database (17): {}".format(err))

    # populate ingredients
    ingredients = make_ingredients()
    current_query = """
    INSERT IGNORE INTO `ingredient`
    (
        `name`,
        `id_unit`,
        `value_unit`,
        `unit_price`,
        `minimum_limit`
    ) VALUES (
        %(name)s,
        (select id_unit from unit where %(id_unit)s like short_label),
        %(value_unit)s,
        %(unit_price)s,
        %(minimum_limit)s
    )
    """
    try:
        cursor.executemany(current_query, ingredients)
    except mysql.connector.Error as err:
        print("Failed inserting database (18): {}".format(err))

list_pk_recipes = [
    recipe["id_recipe"] for recipe in get_pk_list(db, "recipe", ("id_recipe",))
]

list_pk_ingredients = [
    ingredient["id_ingredient"]
    for ingredient in get_pk_list(db, "ingredient", ("id_ingredient",))
]

if not IS_ORDER_ONLY:
    # populate ingredients
    # On a les ingrédients et les recettes
    # Maintenant on distribue au hasard 4 ou 5 ingrédients par recette
    # (on va mettre de la pate à pizza en obligatoire qd même :-)
    current_query = """
    insert ignore into recipe_has_ingredient
    select id_recipe as recipe_id_recipe , 
    (SELECT id_ingredient FROM ingredient where name like '%dough%' ORDER BY RAND() LIMIT 1) as ingredient_id_ingredient,
    (5.0 + RAND())/4.0 as quantity
    from recipe
    """
    try:
        cursor.execute(current_query)
    except mysql.connector.Error as err:
        print("Failed inserting database (19): {}".format(err))

    #  pour chaque recette on affecte 4 à 5 ingrédients au hasard
    current_query = """
        insert ignore into recipe_has_ingredient
            select %(id_recipe)s, id_ingredient, (minimum_limit / 200.0)
            from 
                (select id_ingredient, minimum_limit 
                from ingredient where name not like '%dough%' 
                ORDER BY RAND() LIMIT %(some_limit)s
                ) a
    """
    lst_join_recipes = list()

    for id_recipe in list_pk_recipes:
        lst_join_recipes.append(
            {"id_recipe": id_recipe, "some_limit": random.choice([4, 5])}
        )

    try:
        cursor.executemany(current_query, lst_join_recipes)
    except mysql.connector.Error as err:
        print("Failed inserting database (20): {}".format(err))

    # on constitue les stock pour chaque paire ingrédient/magasin
    for id_pizzeria in list_pk_pizzeria:
        current_query = (
                "insert ignore into stock_ingredient "
                "(ingredient_id_ingredient, date_change, value_stock, pizzeria_id_pizzeria)"
                "select id_ingredient, "
                "now(), value_unit * 100.0, " + str(id_pizzeria) + " from ingredient"
        )
        cursor.execute(current_query)

# maintenant on va pouvoir générer quelques commandes
# 'Order' est rattaché à 3 tables en many 2 many
# invoice / menu_item / person
# note : order <-> person en many 2 many a été
# défini comme tel pour pouvoir historiser les différents
# statuts de la commande sur la table de jointure (datée)

for nb_commandes in range(NB_ORDERS):
    # on choisit un client au hasard
    rand_person = random.choice(list_pk_person)
    # on commence par editer la facture
    # attachée à l'employé qui l'a enregistrée
    current_query = """
    INSERT IGNORE INTO `mydb`.`invoice` (
    `employee_id_employee`,
    `is_paid`,
    `is_on_place`,
    `payment_date`,
    `payment_mode`
    ) VALUES (
        (
        select id_employee 
        from employee 
        where entitlement 
        in ("CASHIER", "WAITER") 
        ORDER BY RAND() LIMIT 1
        ),
    0,
    RAND() > 0.5,
    now(),
    'CB'
    )
    """
    try:
        cursor.execute(current_query)
    except mysql.connector.Error as err:
        print("Failed inserting database (98): {}".format(err))
    # on récupere l'id invoice
    last_id_invoice = cursor.lastrowid

    # créer order (on renseigne juste la date du jour - 6 rand)
    # et l'identifiant de pizzeria
    current_query = """
    INSERT IGNORE INTO
    `order` (`order_date`, `hist_id_pizzeria`)
    VALUES( NOW() - FLOOR(RAND() * 10),
    (SELECT pizzeria_id_pizzeria FROM address_has_pizzeria ahp 
            inner join address a on ahp.address_id_address = a.id_address 
                and ahp.order = 1 and a.is_current = 1
            where a.person_id_person = %(person_id_person)s)
    )
    """
    try:
        cursor.execute(current_query, {"person_id_person": rand_person})
    except mysql.connector.Error as err:
        print("Failed inserting database (22): {}".format(err))

    # on récupere l'id order
    last_id_order = cursor.lastrowid
    # choisir un client au hasard dans la réalité
    # c'est lui qui déclenchera la cmd
    # c'est également lui qui déterminera le restaurant concerné
    # car une personne est attachée à au moins un restau
    # (soit elle l'a choisi -si elle n'est pas authenfiee -,
    # soit le SI choisit en fonction de son adresse)

    # liaison invoice_has_order
    current_query = """
    INSERT IGNORE INTO `invoice_has_order`(
    `order_id_order`, `invoice_id_invoice`
     ) VALUES (
        %(order_id_order)s,
        %(invoice_id_invoice)s
     )
    """
    # créer la jointure order personne avec le statut 'To select'
    try:
        cursor.execute(
            current_query,
            {"order_id_order": last_id_order, "invoice_id_invoice": last_id_invoice},
        )
    except mysql.connector.Error as err:
        print("Failed inserting database (1): {}".format(err))


    # liaison order_has_person
    current_query = """
    INSERT IGNORE INTO `order_has_person`(
    `order_id_order`, `person_id_person`,
     `statut_id_statut`,
     `employee_id_employee`,
     `ts_change`
     ) VALUES (
        %(order_id_order)s,
        %(person_id_person)s,
        (SELECT id_statut FROM statut where label like 'To select'),
        (SELECT employee_id_employee 
        FROM invoice where id_invoice = %(invoice_id_invoice)s),
        NOW()
     )
    """
    # créer la jointure order personne avec le statut 'To select'
    try:
        cursor.execute(
            current_query,
            {"order_id_order": last_id_order,
             "person_id_person": rand_person,
             "invoice_id_invoice": last_id_invoice},
        )
    except mysql.connector.Error as err:
        print("Failed inserting database (1): {}".format(err))

# on a donc X commandes initiées par des clients choisis au hasard
# pour un nb aléatoire de commandes passées on va génèrer un lien avec un set de menu_item
list_order_has_person = [
    (ohp["order_id_order"], ohp["person_id_person"])
    for ohp in get_pk_list(
        db, "order_has_person", ("order_id_order", "person_id_person")
    )
]

list_order_has_menu_item = list()
list_order_has_person_cmd = list()

# boucle inutile dans cette configuration
# conservee pour la generation éventuelle de
# liste de tuples order/person
for tuple_ohp in [(last_id_order, rand_person)]:
    # choix aléatoire de 1 à 5 plats (menu_item) par commande
    # avec une qté aléatoire de 1 à 3 pour chaque plat
    set_menu_item = random.sample(list_pk_menu_item, random.randrange(1, 5))
    local_list_ohm = [
        {
            "order_id_order": tuple_ohp[0],
            "menu_item_id_menu_item": smi,
            "quantity": random.randrange(1, 3),
        }
        for smi in set_menu_item
    ]
    local_list_ohp = [
        {"order_id_order": tuple_ohp[0], "person_id_person": tuple_ohp[1]}
    ]

    list_order_has_menu_item.extend(local_list_ohm)
    list_order_has_person_cmd.extend(local_list_ohp)

current_query = """
    INSERT IGNORE INTO `order_has_menu_item`
    (
        `order_id_order`,
        `menu_item_id_menu_item`,
        `quantity`
    ) VALUES (
        %(order_id_order)s,
        %(menu_item_id_menu_item)s,
        %(quantity)s
    )
"""
try:
    cursor.executemany(current_query, list_order_has_menu_item)
except mysql.connector.Error as err:
    print("Failed inserting database  (2): {}".format(err))

# OK tous ces gens ont selectionné au moins 1 pizza
# c'est parfait maintenant il faut changer le
# statut de leur commande à TO ORDER => en attente de validation
# On vérifie au passage si les commandes peuvent être honorées.

current_query = """
INSERT IGNORE INTO `order_has_person`(
`order_id_order`, `person_id_person`,
 `statut_id_statut`,
 `employee_id_employee`, 
 `ts_change`
 ) VALUES (
    %(order_id_order)s,
    %(person_id_person)s,
    (SELECT id_statut FROM statut where label like 'To order'),
        (
        select id_employee 
        from employee 
        where entitlement 
        in ("CASHIER", "WAITER")
        and pizzeria_id_pizzeria = (select hist_id_pizzeria 
            from `order` where id_order = %(order_id_order)s) 
        ORDER BY RAND() LIMIT 1
        ),
    NOW()
 )
"""
try:
    cursor.executemany(current_query, list_order_has_person_cmd)
except mysql.connector.Error as err:
    print("Failed inserting database  (3): {}".format(err))

# les clients / le serveur ont validé leur commande
# on attend qu'il sortent la CB

current_query = """
INSERT IGNORE INTO `order_has_person`(
`order_id_order`, `person_id_person`,
 `statut_id_statut`,
 `employee_id_employee`,
 `ts_change`
 ) VALUES (
    %(order_id_order)s,
    %(person_id_person)s,
    (SELECT id_statut FROM statut where label like 'To pay'),
        (
        select id_employee 
        from employee 
        where entitlement 
        in ("CASHIER", "WAITER") 
        and pizzeria_id_pizzeria = (select hist_id_pizzeria 
            from `order` where id_order = %(order_id_order)s) 
        ORDER BY RAND() LIMIT 1
        ),
    NOW()
 )
"""
try:
    cursor.executemany(current_query, list_order_has_person_cmd)
except mysql.connector.Error as err:
    print("Failed inserting database  (4): {}".format(err))

# les clients ont payé la pizza s'affiche sur la timeline du pizaoilo

current_query = """
INSERT IGNORE INTO `order_has_person`(
`order_id_order`, `person_id_person`,
 `statut_id_statut`,
 `employee_id_employee`,
 `ts_change`
 ) VALUES (
    %(order_id_order)s,
    %(person_id_person)s,
    (SELECT id_statut FROM statut where label like 'To prepare'),
        (
        select id_employee 
        from employee 
        where entitlement 
        in ("COOK") 
        and pizzeria_id_pizzeria = (select hist_id_pizzeria 
            from `order` where id_order = %(order_id_order)s) 
        ORDER BY RAND() LIMIT 1
        ),    
    NOW()
 )
"""
try:
    cursor.executemany(current_query, list_order_has_person_cmd)
except mysql.connector.Error as err:
    print("Failed inserting database  (5): {}".format(err))

# le pizzaoilo a préparé la commande il va décrémenter le stock
# en fonction des commandes honorées (statut 'To prepare') ...

current_query = """
insert into stock_ingredient (ingredient_id_ingredient,
    date_change, value_stock, pizzeria_id_pizzeria)
select 
    s.ingredient_id_ingredient , 
    DATE_ADD(NOW(), INTERVAL 1 HOUR),
    s.value_stock - a.quantity,
    s.pizzeria_id_pizzeria
from stock_ingredient s
inner join (
    SELECT o.hist_id_pizzeria, rhi.ingredient_id_ingredient, rhi.quantity
        from `order` o 
    inner join order_has_person ohp on ohp.order_id_order = o.id_order
    inner join order_has_menu_item ohm on ohm.order_id_order = o.id_order
    inner join recipe r on ohm.menu_item_id_menu_item = r.menu_item_id_menu_item
    inner join recipe_has_ingredient rhi on r.id_recipe =rhi.recipe_id_recipe 
    inner join ingredient i on i.id_ingredient = rhi.ingredient_id_ingredient 
    inner join unit u on u.id_unit = i.id_unit
    where statut_id_statut = (
        select id_statut from statut where label like 'To prepare'
        ) 
    ) a
    on  a.hist_id_pizzeria = s.pizzeria_id_pizzeria 
    and a.ingredient_id_ingredient = s.ingredient_id_ingredient
    and s.date_change = (
        select max(date_change) from stock_ingredient dc where
        dc.ingredient_id_ingredient = s.ingredient_id_ingredient
        and dc.pizzeria_id_pizzeria  = s.pizzeria_id_pizzeria 
        )
    group by s.ingredient_id_ingredient, s.pizzeria_id_pizzeria 
"""
try:
    cursor.execute(current_query)
except mysql.connector.Error as err:
    print("Failed inserting database  (100): {}".format(err))

print("Stock mis à jour")

# le pizzaoilo a terminé la préparation et décrémenté les stocks
# la commande passe en état 'to deliver'

current_query = """
INSERT IGNORE INTO `order_has_person`(
`order_id_order`, `person_id_person`,
 `statut_id_statut`,
 `employee_id_employee`,
 `ts_change`
 ) VALUES (
    %(order_id_order)s,
    %(person_id_person)s,
    (SELECT id_statut FROM statut where label like 'To deliver'),
            (
        select id_employee 
        from employee 
        where entitlement 
        in ("COOK") 
        ORDER BY RAND() LIMIT 1
        ),
    NOW()
 )
"""
try:
    cursor.executemany(current_query, list_order_has_person_cmd)
except mysql.connector.Error as err:
    print("Failed inserting database  (5): {}".format(err))

cursor.close()
db.commit()
db.close()
