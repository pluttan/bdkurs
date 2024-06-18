import psycopg2
from faker import Faker
import random

fake = Faker('ru_RU')

awards_list = [
    'Лучшая мужская роль', 'Лучшая женская роль', 'Лучшая роль второго плана',
    'Выдающееся исполнение', 'Премия за вклад в искусство', 'Лучшая новая звезда',
    'Премия критиков', 'Премия зрительских симпатий', 'Лучшая комедийная роль',
    'Лучшая драматическая роль', 'Лучший актерский ансамбль', 'Лучший актер озвучивания',
    'Лучший международный актер', 'Лучшая роль в главной роли', 'Лучшая роль второго плана',
    'Лучшее исполнение в короткометражке', 'Лучшее исполнение в полнометражном фильме',
    'Лучшее исполнение в спектакле', 'Лучшее исполнение в мюзикле',
    'Лучшее исполнение в телесериале', 'Лучшее исполнение в веб-сериале',
    'Лучшее исполнение в рекламе', 'Лучшее исполнение в музыкальном видео',
    'Лучшее исполнение в анимационном фильме', 'Лучшее исполнение в видеоигре',
    'Лучший детский актер', 'Лучший подростковый актер', 'Лучший актер старшего возраста',
    'Лучший мужской актер', 'Лучшая женская актерская роль', 'Лучший трансгендерный актер',
    'Актер года', 'Лучший прорыв', 'Лучшее гостевое исполнение', 'Лучшее камео',
    'Лучший злодей', 'Лучший герой', 'Лучший дуэт', 'Лучший актерский дебют',
    'Лучшее исполнение в исторической роли', 'Лучшее исполнение в научно-фантастической роли',
    'Лучшее исполнение в фэнтезийной роли', 'Лучшее исполнение в роли ужасов',
    'Лучшее исполнение в боевой роли', 'Лучшее исполнение в комедийной роли',
    'Лучшее исполнение в драматической роли', 'Лучшее исполнение в романтической роли',
    'Лучшее исполнение в триллере', 'Лучшее исполнение в военной роли',
    'Лучшее исполнение в вестерне', 'Лучшее исполнение в документальном фильме'
]

def insert_actors(cursor):
    for i in range(1000):
        name = fake.name()
        birth_date = fake.date_of_birth(minimum_age=18, maximum_age=65)
        f = open(f'/Volumes/pr/BDkurs/imgs/{i+1}.jpeg', 'rb')
        photo = f.read()
        f.close()
        experience = f'{random.randint(1, 50)} years'
        awards = random.sample(awards_list, random.randint(0, 10))
        cursor.execute(
            'INSERT INTO \'Актеры\' (\'ФИО\', \'ДатаРождения\', \'Фото\', \'СтажРаботы\', \'ЗваниеНаграды\') '
            'VALUES (%s, %s, %s, %s, %s)',
            (name, birth_date, photo, experience, awards)
        )

def insert_plays(cursor):
    for i in range(2000):
        title = fake.sentence(nb_words=random.randint(2,3), variable_nb_words=True)
        budget = random.randint(1000, 10000)
        year = random.randint(1900, 2023)
        age_limit = f'{random.randint(0, 18)}+'
        cursor.execute(
            'INSERT INTO \'Спектакли\' (\'Название\', \'Бюджет\', \'ГодПостановки\', \'ОграничениеПоВозрасту\', \'КодПьесы\') '
            'VALUES (%s, %s, %s, %s, %s)',
            (title, budget, year, age_limit, i + 1)
        )

def insert_contracts(cursor):
    for i in range(1000):
        start_date = fake.date_between(start_date='-20y', end_date='today')
        end_date = fake.date_between(start_date='today', end_date='+7y')
        salary = random.randint(30000, 100000)
        cursor.execute(
            'INSERT INTO \'Контракт\' (\'ДатаПриема\', \'ДатаУвольнения\', \'Ставка\', \'КодАктера\') '
            'VALUES (%s, %s, %s, %s)',
            (start_date, end_date, salary, i + 1)
        )

def insert_employment(cursor):
    for _ in range(1000000):
        actor_id = random.randint(1, 1000)
        play_id = random.randint(1, 2000)
        cursor.execute(
            'INSERT INTO \'ЗанятостьВСпектаклях\' (\'КодСпектакля\', \'КодАктера\') '
            'VALUES (%s, %s)',
            (play_id, actor_id)
        )

def insert_rehearsals(cursor):
    for _ in range(80000):
        date_time = fake.date_time_between(start_date='-20y', end_date='now')
        duration = f'{random.randint(1,4)}:{random.randint(0, 59)}:00'
        read_through = fake.boolean()
        play_id = random.randint(1, 2000)
        cursor.execute(
            'INSERT INTO \'Репетиции\' (\'ДатаВремя\', \'Продолжительность\', \'Читка\', \'КодСпектакля\') '
            'VALUES (%s, %s, %s, %s)',
            (date_time, duration, read_through, play_id)
        )

def insert_scenes(cursor):
    for i in range(40000):
        title = f'{fake.sentence(nb_words=random.randint(2,3), variable_nb_words=True)}'
        duration = f'00:{random.randint(1, 30)}:00'
        play_id = random.randint(1, 2000)
        cursor.execute(
            'INSERT INTO \'Сцены\' (\'Название\', \'Продолжительность\', \'КодПьесы\') '
            'VALUES (%s, %s, %s)',
            (title, duration, play_id)
        )

def insert_roles(cursor):
    for i in range(1000000):
        title = f'{fake.sentence(nb_words=random.randint(1, 2), variable_nb_words=True)}'
        main_role = fake.boolean()
        play_id = random.randint(1, 2000)
        actor_id = random.randint(1, 1000)
        cursor.execute(
            'INSERT INTO \'Роли\' (\'НазваниеРоли\', \'Главная\', \'КодПьесы\', \'КодАктера\') '
            'VALUES (%s, %s, %s, %s)',
            (title, main_role, play_id, actor_id)
        )

def insert_role_engagement(cursor):
    for _ in range(1000000):
        role_id = random.randint(1, 1000000)
        scene_id = random.randint(1, 40000)
        cursor.execute(
            'INSERT INTO \'ЗанятостьРолиВСценах\' (\'КодРоли\', \'КодСцены\') '
            'VALUES (%s, %s)',
            (role_id, scene_id)
        )

def insert_scenes_in_rehearsals(cursor):
    for _ in range(80000):
        rehearsal_id = random.randint(1, 80000)
        scene_id = random.randint(1, 40000)
        cursor.execute(
            'INSERT INTO \'СценыВРепетициях\' (\'КодРепетиции\', \'КодСцены\') '
            'VALUES (%s, %s)',
            (rehearsal_id, scene_id)
        )

def insert_plays_details(cursor):
    for i in range(2000):
        title = f'{fake.sentence(nb_words=random.randint(2,3), variable_nb_words=True)}'
        year = random.randint(1900, 2023)
        author = fake.name()
        cursor.execute(
            'INSERT INTO \'Пьесы\' (\'Название\', \'ГодВыпуска\', \'Автор\') '
            'VALUES (%s, %s, %s)',
            (title, year, author)
        )

def main():
    try:
        conn = psycopg2.connect(
            dbname='Занятость актеров театра',
            user='pluttan',
            password=input('Password: '),
            host='localhost',
            port='5432'
        )
        print('Connected to the database')
        cursor = conn.cursor()
        print('generation actors')
        insert_actors(cursor)
        conn.commit()
        print('generation plays')
        insert_plays(cursor)
        conn.commit()
        print('generation contracts')
        insert_contracts(cursor)
        conn.commit()
        print('generation employment')
        insert_employment(cursor)
        conn.commit()
        print('generation rehearsals')
        insert_rehearsals(cursor)
        conn.commit()
        print('generation scenes')
        insert_scenes(cursor)
        conn.commit()
        print('generation roles')
        insert_roles(cursor)
        conn.commit()
        print('generation role engagement')
        insert_role_engagement(cursor)
        conn.commit()
        print('generation scenes in rehearsals')
        insert_scenes_in_rehearsals(cursor)
        conn.commit()
        print('generation plays details')
        insert_plays_details(cursor)
        conn.commit()
        print('Data inserted successfully')
    except Exception as e:
        print(f'Error: {e}')
    finally:
        if conn:
            conn.close()

if __name__ == '__main__':
    main()

