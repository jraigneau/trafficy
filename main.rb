# -*- coding: utf-8 -*-
require 'rubygems'
require 'data_mapper'
require 'sinatra'
require 'haml'
require 'date'
require 'nokogiri'


#https://maps.google.fr/maps?saddr=14+Rue+de+Lorraine,+Asni%C3%A8res-sur-Seine&daddr=Ris-Orangis

## Configurations 
enable :sessions

configure :development do
  DataMapper.setup(:default, "sqlite3://#{Dir.pwd}/development.db")
end

configure :production do
   DataMapper.setup(:default, ENV['DATABASE_URL'])
  set :port, ENV['PORT']
  set :bind, ENV['IP']
end

set :root, File.dirname(__FILE__)
set :views, "#{File.dirname(__FILE__)}/views"
set :public_folder, "#{File.dirname(__FILE__)}/public"
set :sessions, true

## Models
class Path
  include DataMapper::Resource  
  property :id,                   Serial
  property :origin,               String
  property :destination,          String
  property :morning_interval,     Date
  property :evening_interval,     Date
  has n, :results
end

class Result
  include DataMapper::Resource  
  property :id,                   Serial
  property :date,                  Date
  property :minutes,               Integer
  belongs_to :path 
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

 