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


#https://maps.google.fr/maps?saddr=14+Rue+de+Lorraine,+Asni%C3%A8res-sur-Seine&daddr=26+Rue+de+la+Rochefoucauld,+Boulogne-Billancourt

get '/run/:date' do
  if :date != ""
    Path.each do |x|
      doc = Nokogiri::HTML(open("https://maps.google.fr/maps?saddr=#{ x.origin }&daddr=#{ x.destination }"))  
      data = doc.xpath("//*[@id='altroute_0']/div/div[2]/span")
      if data.length != 0
        data = data.text.split(":")[1].split(" ")
        #first result: "Dans les conditions actuelles de circulation : 1 heure 10 min" 
      else
        data = doc.xpath("//*[@id='altroute_0']/div/div[1]/span").text.split("km")[1].split(" ")
      end
      min = 0
      if data.length > 2 #more than 1 hour
        min = data[0].to_i*60 + data[2].to_i
      else
        min = data[0].to_i
      end
      puts "nb min:" + min.to_s

    end
    
      end
end


 