# -*- coding: utf-8 -*-
require 'rubygems'
require 'sinatra'
require 'haml'
require 'date'
require 'nokogiri'
require 'open-uri'
require 'sequel'
require "sinatra/reloader" if development?

require './init'
require './utils'

#https://maps.google.fr/maps?saddr=14+Rue+de+Lorraine,+Asni%C3%A8res-sur-Seine&daddr=Ris-Orangis
#0,15,30,45 6-10  * * 1-5   root    /bin/ash /root/trafficy/trafficy.sh

## Helpers
helpers do
  def link_to text, url
    "<a href='#{ URI.encode url }'>#{ text }</a>"
  end
  
  #vérifie si la date est le matin ou le soir (après / avant 13h) => defaut = matin
  def is_morning?(myDate)
    if myDate.nil? or myDate == 0
      true
    else
      if DateTime.strptime(myDate, "%Y-%m-%d_%H-%M").hour < 13
        true
      else
        false
      end
    end  
  end  
end


get '/' do
  @nav = 'index'
  haml :index
end

get '/about' do
  @nav = 'about'
  haml :index
end

get '/create' do
  @nav = 'create'
  haml :index
end

get '/paths/list' do
  @nav = 'paths/list'
  @paths = []
  Path.each do |path|
    origin = path.origin
    destination = path.destination
    min_s,max_s,mean_s = calc_min_max_min_for(path,0) #evening
    min_m,max_m,mean_m = calc_min_max_min_for(path,1) #morning
    @paths <<   {:id => path.id, :origin => origin, :destination => destination, 
                  :min_s => min_s, :max_s => max_s, :mean_s => mean_s,
                  :min_m => min_m, :max_m => max_m, :mean_m => mean_m
                } 
  end
  haml :list
end

get '/paths/delete/:id' do
  if params[:id]
    id = params[:id]
    begin
      #Path.where(:id => id).delete
    rescue Exception => e
      logger.error "/delete/#{id} :" + e.message
    end
  end
  redirect '/paths/list'
end

get '/paths/stats/:id' do
  if params[:id]
    id = params[:id]
    begin  
      data = [
                [-9.7, 9.4],
                [-8.7, 6.5],
                [-3.5, 9.4],
                [-1.4, 19.9],
                [0.0, 22.6],
                [2.9, 29.5],
                [9.2, 30.7],
                [7.3, 26.5],
                [4.4, 18.0],
                [-3.1, 11.4],
                [-5.2, 10.4],
                [-13.5, 9.8]
            ]
      xAxis = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec']
      @graph1 = {:title => "Répartition des temps de trajets le matin", :subtitle => "Calcul basé sur x jours",:xAxis => xAxis,:data => data}
    rescue Exception => e
      logger.error "/stats/#{id} :" + e.message
    end
  end
  @nav = ''
  haml :stats
end



# [ ]
#https://maps.google.fr/maps?saddr=14+Rue+de+Lorraine,+Asni%C3%A8res-sur-Seine&daddr=26+Rue+de+la+Rochefoucauld,+Boulogne-Billanco
#0,15,30,45      6-10    *       *       1-5     root    /bin/ash /root/trafficy/trafficy.sh
#0,15,30,45      16-20    *       *       1-5     root    /bin/ash /root/trafficy/trafficy.sh

get '/run/:now' do
  if params[:now]
    Path.each do |path|
      begin
        is_morning = 1
        origin = URI::encode(path.origin)
        destination = URI::encode(path.destination)
        if !is_morning?(params[:now]) #Si c'est le soir, on inverse destination et origin
          origin,destination = destination, origin
          is_morning = 0
        end
        #logger.info "https://maps.google.fr/maps?saddr=#{ origin }&daddr=#{ destination }"
        doc = Nokogiri::HTML(open("https://maps.google.fr/maps?saddr=#{ origin }&daddr=#{ destination }"))  
        data = doc.xpath("//*[@id='altroute_0']/div/div[2]/span")
        logger.info data
        if data.length != 0 and !data.text.split(":")[0].include?("Aucune information sur le trafic") #il y a des bouchons
          logger.info "Data.test.split(':'): " + data.text.split(":").join(",")
          data = data.text.split(":")[1].split(" ")
          #first result: "Dans les conditions actuelles de circulation : 1 heure 10 min" 
        elsif doc.xpath("//*[@id='altroute_0']/div/div[1]/span").length != 0 #pas de bouchon => pas le même code html
          data = doc.xpath("//*[@id='altroute_0']/div/div[1]/span[2]").text.split(" ")
        end #les autres cas tomberont en erreur => récupération via le rescue
            
        min = 0
        if data.length > 2 #more than 1 hour
          min = data[0].to_i*60 + data[2].to_i
        else
          min = data[0].to_i
        end
        logger.info "origin: #{origin} dest: #{destination} nb min:#{min.to_s}"
        Result.create(:date => DateTime.strptime(params[:now], "%Y-%m-%d_%H-%M"), :minutes => min, :path_id => path.id, :is_morning => is_morning)
        
        rescue Exception => e
          Log.create(:message => e.message, :path_id => path.id, :run_date => DateTime.strptime(params[:now], "%Y-%m-%d_%H-%M"))
          logger.error "/run/ :" + e.message
        end
      end
  end
  return "200"
end


 