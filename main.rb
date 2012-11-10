# -*- coding: utf-8 -*-
require 'rubygems'
require 'sinatra'
require 'haml'
require 'date'
require 'nokogiri'
require 'open-uri'
require 'sequel'


#https://maps.google.fr/maps?saddr=14+Rue+de+Lorraine,+Asni%C3%A8res-sur-Seine&daddr=Ris-Orangis

## Configurations 
enable :sessions

configure :development do
  DB = Sequel.sqlite('trafficy-dev.db')
  set :port, ENV['PORT']
  set :bind, ENV['IP']
end

configure :production do
  Sequel.connect(ENV['DATABASE_URL'])
end

set :root, File.dirname(__FILE__)
set :views, "#{File.dirname(__FILE__)}/views"
set :public_folder, "#{File.dirname(__FILE__)}/public"
set :sessions, true

## Models
DB.create_table :paths do
  primary_key :id
  String  :origin
  String  :destination
  Date    :morning_interval
  Date    :evening_interval
end

DB.create_table :results do
  primary_key :id
  Date      :date
  Integer   :minutes
  foreign_key :path_id, :paths
end

class Path < Sequel::Model
    one_to_many :results
end

class Result < Sequel::Model
    many_to_one :path
end


## Helpers
helpers do
  def link_to text, url
    "<a href='#{ URI.encode url }'>#{ text }</a>"
  end 
end

get '/' do
  haml :index
end

get '/test' do
  doc = Nokogiri::HTML(open('https://maps.google.fr/maps?saddr=14+Rue+de+Lorraine,+Asni%C3%A8res-sur-Seine&daddr=Ris-Orangis'))  
  puts doc.xpath("//*[@id='altroute_0']/div/div[2]/span").text
end


 