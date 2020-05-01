require 'sinatra'
require 'sinatra/reloader'
require 'sinatra/cookies' # 忘れずに！
require 'pg'

enable :sessions  # サーバーの再起動を忘れずに！！
set :public_folder, 'public'

# client = PG::connect(
#   :host => "localhost",
#   :user'lagoon',
#   :password => 'pass',
#   :dbname => "myapp")

client = PG::connect(
  dbname: 'sinatra_task'
)

# def db
#   client = PG::connect(
#   :host => "localhost",
#   :user'lagoon',
#   :password => 'pass',
#   :dbname => "myapp")
# end


# get '/' do
#   'Hello world!'
# end

# get '/hello' do
#   "<h1>Hello #{params[:name]}!</h1>"
# end


get '/index' do

  @res = client.exec('select * from posts;')


  erb :index
end

post '/post' do
  name=params[:user_name]
  email=params[:user_email]
  msg=params[:user_message]

  client.exec("insert into posts(name, email, msg) values('#{name}', '#{email}', '#{msg}');")

  redirect '/index'
end

# get '/hello' do
#   "<h1>Hello #{params[:name]}!</h1>"
# end

get '/hello' do
  if params[:name]
    session[:name] = params[:name]
  end

  "<h1>Hello #{session[:name]}!</h1>"

  erb :hello
end

# get '/user/:name/:age' do
#  "<h1>#{params[:name]},#{params[:age]}</h1>"
# end

# get '/place/lagoon' do
#   @user = "kazushi"
#   erb :design
# end

get '/form' do
  erb :form
end

post '/form' do
  @name = params[:name]
  @email = params[:email]
  @content = params[:content]

  # binding.irb

  # ファイルに保存する
  File.open("form.txt", mode = "a"){|f|
    f.write("#{@name},#{@email},#{@content}\n")
  }
  redirect '/form'
end

get '/list' do
  erb :list
end

get "/image" do
  @images = Dir.glob("./public/images/*").map{|path| path.split('/').last }
  erb :image
end

post '/image' do
  @filename = params[:file][:filename]
  file = params[:file][:tempfile]
  # binding.irb
  File.open("./public/images/#{@filename}", 'wb') do |f|
    f.write(file.read)
  end
  # erb :show_image
  redirect '/image'
end


get '/users' do
  sql = "select * from users;"
  @users = db.exec_params(sql).to_a

  erb :users
end

get '/users/:id' do
  id = params[:id]
  sql = "select * from users where id = #{id};"
  users = db.exec_params(sql).to_a
  @user = users[0]

  erb :user
end
