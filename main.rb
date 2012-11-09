# -*- coding: utf-8 -*-
require 'rubygems'
require 'data_mapper'
require 'sinatra'
require 'haml'
require 'date'




## Congurations 
enable :sessions

configure :development do
  DataMapper.setup(:default, "sqlite3://#{Dir.pwd}/development.db")
end

configure :production do
    require 'newrelic_rpm'
   DataMapper.setup(:default, ENV['DATABASE_URL'])
end

set :root, File.dirname(__FILE__)
set :views, "#{File.dirname(__FILE__)}/views"
set :public, "#{File.dirname(__FILE__)}/public"
set :sessions, true


## Models
class Run
  include DataMapper::Resource  
  property :id,                   Serial
  property :id_user,              String
  property :date,                 Date
  property :duree,                Float
  property :distance,             Float
  property :commentaires,         Text
  property :id_post,              String
end

DataMapper.auto_upgrade!
#DataMapper.auto_migrate! #si changement de schéma à faire apparaître en production
DataMapper::Model.raise_on_save_failure = false #permet de savoir si tout est bien sauvegardé, à utiliser avec rescue

## Helpers
helpers do
  def link_to text, url
    "<a href='#{ URI.encode url }'>#{ text }</a>"
  end 
end

get '/' do
  haml :index
end

 