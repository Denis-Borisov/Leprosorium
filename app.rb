#encoding: utf-8
require 'rubygems'
require 'sinatra'
require 'sinatra/reloader'
require 'sqlite3'


def init_db
 	@db = SQLite3::Database.new 'leprosorium.db'
 	@db.results_as_hash = true	
end

# вызывается при перезагрузке любой страницы

before do
	# инициализация БД

	init_db
end

# configure вызывается каждый раз при конфигурации при инициализации приложения:
# когда изменился код программы или перезагрузилась страница

configure do
	# инициализации БД

	init_db
	# создает таблицу, если таблица не существует

	@db.execute 'CREATE TABLE IF NOT EXISTS Posts ( id INTEGER PRIMARY KEY AUTOINCREMENT, created_date DATE, content TEXT)'	
end

get '/' do
	# выбираем список постов из БД

	@results = @db.execute 'select * from Posts order by id desc'

	erb :index			
end

# обработчик get-запроса / new
# (браузер получает страницу с сервера)

get '/new' do
  erb :new
end

# обработчик post-запроса / new
# (браузер отправляет данные на сервер)

post '/new' do
  # получаем переменную из post-запроса
  content = params[:content]

  if content.length <= 0
  	@error = 'Type post text'
  	return erb :new
  end

  # сохранение данных в БД	  
  @db.execute 'insert into Posts (content, created_date) values (?, datetime())', [content]

  erb "You typed: #{content}"

end