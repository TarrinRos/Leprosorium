# encoding: utf-8

require 'rubygems'
require 'sinatra'
require 'sinatra/reloader'
require "sqlite3"

def init_db
  @db = SQLite3::Database.new './public/leprosorium.db'
  @db.results_as_hash = true
end

before do
  init_db
end

configure do
  init_db
  @db.execute 'create table if not exists Posts (
              id INTEGER PRIMARY KEY AUTOINCREMENT,
              created_date DATE,
              content TEXT
  )'
end

get '/' do
  # posts list from DataBase
  @results = @db.execute 'select * from Posts order by id desc'
  erb :index
end

get '/new' do
  erb :new
end

post '/new' do
  @content = params[:content]
  if @content.length < 1
    @error = 'Type your text please'
    return erb :new
  end
  # saving data to database
  @db.execute 'insert into Posts (content, created_date) values (?, datetime())', [@content]
  # redirect to main page
  redirect to '/'
  erb "You typed #{@content}"
end

# Returns posts by Id
get '/details/:post_id' do
  # get variables from url
  post_id = params[:post_id]
  # get only one post from db
  results = @db.execute 'select * from Posts where id =?', [post_id]
  @row = results[0]
  erb :details
end

post '/details/:post_id' do
  post_id = params[:post_id]
  @content = params[:content]
  erb "You typed comment #{@content} with #{post_id}"
end
