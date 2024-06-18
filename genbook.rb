require 'active_record'
require 'faker'
require 'google_translate_scraper'

# Настройка соединения с базой данных
ActiveRecord::Base.establish_connection(
  adapter: 'postgresql',
  host: 'localhost',
  username: 'pluttan',
  password: 'Pluttan2004',
  database: 'Занятость актеров театра'
)

# Определение моделей
class Spectacle < ActiveRecord::Base
  self.table_name = 'Спектакли'
end

class Play < ActiveRecord::Base
  self.table_name = 'Пьесы'
end

# Функция перевода
def translate_text(text, target_lang = 'ru')
  t = GoogleTranslateScraper.translate(
    :source_language => 'en', 
    :target_language => 'ru', 
    :search_text => text)
  puts t.translations.first
  t.translations.first
end

# Обновление названий спектаклей
updated_spectacles = 0
Spectacle.find_each do |spectacle|
  new_title = translate_text(Faker::Book.title)
  spectacle.update(Название: new_title)
  updated_spectacles += 1
end

puts "Названия спектаклей обновлены: #{updated_spectacles} записей."

# Обновление названий пьес
updated_plays = 0
Play.find_each do |play|
  new_title = translate_text(Faker::Book.title)
  play.update(Название: new_title)
  updated_plays += 1
end

puts "Названия пьес обновлены: #{updated_plays} записей."
puts "Обновление завершено!"

