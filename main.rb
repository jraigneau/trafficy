# -*- coding: utf-8 -*-
require 'rubygems'
require 'sinatra'
require 'haml'
require 'date'
require 'nokogiri'
require 'open-uri'
require 'sequel'

require './init'

#https://maps.google.fr/maps?saddr=14+Rue+de+Lorraine,+Asni%C3%A8res-sur-Seine&daddr=Ris-Orangis


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
  data = doc.xpath("//*[@id='altroute_0']/div/div[2]/span").text.split(":")[1].split(" ")
  #first result: "Dans les conditions actuelles de circulation : 1 heure 10 min" 
  min = 0
  if data.length > 2 #more than 1 hour
    min = data[0].to_i*60 + data[2].to_i
  else
    min = data[0].to_i
  end
  puts "nb min:" + min.to_s
end


 