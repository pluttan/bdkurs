import psycopg2
from deep_translator import GoogleTranslator
from faker import Faker
from random import randint

def translate_and_update_table(db_config,
                               table_name, column_name, id_column, 
                               record_id, src_lang='en', dest_lang='ru'):
    cursor.execute(f"SELECT {column_name} FROM {table_name} WHERE {id_column} = %s", (record_id,))
    result = cursor.fetchone()
    if result:
        a = Faker('ru_RU')
        original_text = result[0]
        translator = GoogleTranslator(source=src_lang, target=dest_lang)
        translated_text = translator.translate(original_text)
        cursor.execute(
            f"UPDATE {table_name} SET {column_name} = %s WHERE {id_column} = %s",
            (translated_text, record_id))
        print("Перевод выполнен и значение обновлено в таблице.", id_column, record_id)
    else:
        print("Запись не найдена.")
   
db_config = {
    'dbname': 'Занятость актеров театра',
    'user': 'pluttan',
    'password': 'Pluttan',
    'host': 'localhost',
    'port': '5432'
}
conn = psycopg2.connect(**db_config)
cursor = conn.cursor()
for i in range(1, 2001):
    translate_and_update_table(db_config, 
                               'Пьесы',     'Название', 'КодПьесы',     
                               i, src_lang='en', dest_lang='ru')
    translate_and_update_table(db_config, 
                               'Спектакли',     'Название', 'КодСпектакля',     
                               i, src_lang='en', dest_lang='ru')
    if i%1000 == 0: conn.commit()
cursor.close()
conn.close()

