from faker import Faker
import random
import mysql.connector
import itertools

DB_USERNAME = '<USERNAME>'
DB_PASSWORD ='<PASSWORD>'
DB_NAME = 'mydb'
DB_HOST = '127.0.0.1'

# nb items
NB_PERSONS = 100
NB_PIZZERIAS = 10
NB_EMPLOYEES = NB_PIZZERIAS * 6

fake = Faker('fr_FR')
fake_italiano = Faker('it_IT')


def getDB():
    return mysql.connector.connect(
        **{
            "user": DB_USERNAME,
            "password": DB_PASSWORD,
            "host": DB_HOST,
            "port": 3306,
            "database": DB_NAME
        }
    )


def make_persons(nb):
    # generate people
    fake_persons = [{
        'nick_name': 'FAKE_OWNER',
        'first_name': 'FAKE_FIRST_NAME',
        'last_name': 'FAKE_LAST_NAME',
        'phone_number': '01 23 45 67 89',
        'email': 'fake@email.com'
    }]

    for _ in range(1, nb):
        last_name = fake.last_name()
        first_name = fake.first_name()
        nick_name = last_name[0:4] + '_' + str(random.randrange(9999))
        phone_number = '06' + " {:02d} {:02d} {:02d} {:02d}" \
            .format(random.randrange(99)
                    , random.randrange(99)
                    , random.randrange(99)
                    , random.randrange(99))
        email = first_name + '.' + last_name + '@' + fake.domain_name(levels=1)

        fake_persons.append({'nick_name': nick_name,
                             'first_name': first_name,
                             'last_name': last_name,
                             'phone_number': phone_number,
                             'email': email})
    return fake_persons


def make_an_address(id_person):
    return {
        'num_address': '0',
        'person_id_person': str(id_person),
        'is_current': 1,
        'street_num': random.randint(1, 200),
        'street': fake.street_name(),
        'city': fake.city(),
        'zip_code': f'{random.randint(1000, 99000):05}',
        'country': 'France',
        'localization': 'ASK_GG'
    }


def make_an_pizzeria_address(actual_list):
    city = str(fake.city())
    street = str(fake.street_name())
    rand_name = random.choice([city, street])
    is_vowel = str(rand_name).upper().startswith(('A', 'E', 'I', 'O', 'U', 'Y'))
    article = "du " if (rand_name.upper().startswith((
        'CHEMIN', 'PASSAGE', 'BOULEVARD'))) else (
        "de la " if rand_name.upper().startswith('RUE') else (
            "de l'" if rand_name.upper().startswith('AVENUE') else (
                "d'" if is_vowel is True else "de "
            )
        )
    )
    while True:
        to_test = {
            'name':
                random.choice(['Restaurant ', 'Pizzeria ', 'OC Pizza ']) +
                article +
                rand_name,
            'address': str(random.randint(1, 200)) + ", " + street,
            'city': city,
            'zip_code': f'{random.randint(1000, 99000):05}',
            'country': 'France',
            'localization': 'ASK_GG'
        }

        if to_test not in actual_list:
            break
    return to_test


def make_employees(nb, list_pk_pizzeria):
    # generate employee
    fake_employees = list()
    count_for_each = dict()
    entitlement = ['MANAGER', 'COOK', 'CASHIER', 'DELIVERER', 'WAITER']

    for _ in range(1, nb):
        last_name = fake_italiano.last_name()
        first_name = fake_italiano.first_name()
        random_pizzeria = random.choice(list_pk_pizzeria)
        count_for_each[random_pizzeria] = \
            0 if random_pizzeria not in count_for_each else \
                count_for_each[random_pizzeria] + 1
        num_registration = str(random_pizzeria) + '-' + str(count_for_each[random_pizzeria] + 1)
        phone_number = '06' + " {:02d} {:02d} {:02d} {:02d}" \
            .format(random.randrange(99)
                    , random.randrange(99)
                    , random.randrange(99)
                    , random.randrange(99))
        email = first_name + '.' + last_name + '@' + fake.domain_name(levels=1)

        fake_employees.append(
            {
                'pizerria_id_pizzeria': str(random_pizzeria),
                'num_registration': num_registration,
                'first_name': first_name,
                'last_name': last_name,
                'entitlement': entitlement[min(count_for_each[random_pizzeria], 4)],
                'hire_date': '2020-06-16',
                'password': 'TOFILL',
                'email': email,
                'phone_number': phone_number
            }
        )
    return fake_employees


def get_pk_list(db, table_name, pk_names):
    """
        get the list id of recorded
        """
    # list 2 return
    substitutes_list = list()

    cursor = db.cursor()
    cursor.execute("select " +
                   ",".join(pk_names) +
                   "    from  {}".format(table_name)
                   )

    for a_row in cursor:
        map_row = dict(zip(cursor.column_names, a_row))
        substitutes_list.append(map_row)

    # cursor.close()
    return substitutes_list


db = getDB()
##### populate table 'person' #####
persons = make_persons(NB_PERSONS)
current_query = """
INSERT IGNORE INTO person (nick_name, first_name, last_name, phone_number, email) 
                VALUES (%(nick_name)s,
                %(first_name)s,
                %(last_name)s,
                %(phone_number)s,
                %(email)s)
"""
cursor = db.cursor()
try:
    cursor.executemany(current_query, persons)
except mysql.connector.Error as err:
    print("Failed inserting database: {}".format(err))
db.commit()

##### populate table 'address' #####
addresses = list()
list_pk = [person['id_person'] for person in get_pk_list(db, 'person', ('id_person',))]

for id in list_pk:
    addresses.append(make_an_address(id))

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
    print("Failed inserting database: {}".format(err))

##### populate table 'pizerria' #####
addresses_pizzeria = list()
for _ in range(NB_PIZZERIAS):
    addresses_pizzeria.append(make_an_pizzeria_address(addresses_pizzeria))

current_query = """
    INSERT IGNORE INTO pizzeria
    (name, city, address,
    localization, create_time)
    VALUES (
    %(name)s,
    %(city)s,
    %(address)s,
    %(localization)s,
    CURRENT_TIMESTAMP);
"""

try:
    cursor.executemany(current_query, addresses_pizzeria)
except mysql.connector.Error as err:
    print("Failed inserting database: {}".format(err))

##### jointure 'pizerria / adresse'  #####
##### Note : les addresses des pizzerias ne correspondront pas aux localisations
##### des adresses client. Pour l'instant dans système de localisation la distribution
##### géographique se fait au hasard
list_pk_address = [person['id_address'] for person in get_pk_list(db, 'address', ('id_address',))]
list_pk_pizzeria = [pizzeria['id_pizzeria'] for pizzeria in get_pk_list(db, 'pizzeria', ('id_pizzeria',))]
jointures_addresses_pizzeria = [dict({'address_id_address': pk_address,
                                      'pizzeria_id_pizzeria': random.choice(list_pk_pizzeria)
                                      })
                                for pk_address in list_pk_address]

current_query = """
    INSERT IGNORE INTO address_has_pizzeria
    (address_id_address, pizzeria_id_pizzeria, 
    last_date_cmd)
    VALUES (%(address_id_address)s,
    %(pizzeria_id_pizzeria)s,
    now() - INTERVAL FLOOR(RAND() * 365) DAY );
"""
try:
    cursor.executemany(current_query, jointures_addresses_pizzeria)
except mysql.connector.Error as err:
    print("Failed inserting database: {}".format(err))

##### populate table 'employee' #####
# on garde list_pk_pizzeria

employees = make_employees(NB_EMPLOYEES, list_pk_pizzeria)

current_query = """
    INSERT IGNORE INTO employee (
    pizerria_id_pizzeria, num_registration, first_name,
    last_name, entitlement, hire_date,
    password, email, phone_number, create_time
    )  VALUES (
        %(pizerria_id_pizzeria)s,
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
    print("Failed inserting database: {}".format(err))

##### populate table 'role' #####
##### 1 seul role pour le moment
##### tout les employés seront branchés dessus
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
    print("Failed inserting database: {}".format(err))

list_pk_role = [role['id_role'] for role in get_pk_list(db, 'role', ('id_role',))]
list_pk_employee = [employee['id_employee'] for employee in get_pk_list(db, 'employee', ('id_employee',))]

jointures_category_employee = [dict({'employee_id_employee': pk_employee,
                                      'role_id_role': list_pk_role[0]
                                      })
                                for pk_employee in list_pk_employee]

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
    cursor.executemany(current_query, jointures_category_employee)
except mysql.connector.Error as err:
    print("Failed inserting database: {}".format(err))

### populate table 'category'
### idem  1 seule catégorie pour le moment

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
    print("Failed inserting database: {}".format(err))


cursor.close()
db.commit()
db.close()
