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
  #vérifie si la date est le matin ou le soir (après / avant 13h) => defaut = matin
  def is_morning? date
    if date.nil? or date == 0
        true
    else
        if DateTime.strptime(date, "%Y-%m-%d_%H-%M").hour < 13
            true
        else
            false
        end
    end
            
  end
end

get '/' do
  haml :index
end


#https://maps.google.fr/maps?saddr=14+Rue+de+Lorraine,+Asni%C3%A8res-sur-Seine&daddr=26+Rue+de+la+Rochefoucauld,+Boulogne-Billancourt

get '/run/:date' do
    if :date != ""
        Path.each do |x|
            origin = x.origin
            destination = x.destination
            if !is_morning(:date) #Si c'est le soir, on inverse destination et origin
                origin,destination = destination, origin
            end
            
            doc = Nokogiri::HTML(open("https://maps.google.fr/maps?saddr=#{ origin }&daddr=#{ destination }"))  
            data = doc.xpath("//*[@id='altroute_0']/div/div[2]/span")
            if data.length != 0 #il y a des bouchons
                data = data.text.split(":")[1].split(" ")
                #first result: "Dans les conditions actuelles de circulation : 1 heure 10 min" 
            else #pas de bouchon => pas le même code html
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


 