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
    min_s,max_s,mean_s = calc_min_max_mean_for(path, 0) #evening
    min_m,max_m,mean_m = calc_min_max_mean_for(path, 1) #morning
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
      message = "Exception for path #{id} in delete// e.message"
      location = "/delete/"
      Log.create(:message => message, :location => location)
      logger.error "/delete/#{id} :" + e.message
    end
  end
  redirect '/paths/list'
end

get '/paths/stats/:id' do
  if params[:id]
    id = params[:id]
    begin
      data,xAxis = calc_chart_bar(id,6..10)
      path = Path.where(:id => id).first
      @origin = path.origin
      @destination  = path.destination
      @graph1 = {:title => "Amplitude des temps de trajets le matin", :subtitle => "#{@origin} >> #{@destination}",:xAxis => xAxis,:data => data}
      data,xAxis = calc_chart_bar(id,16..20)
      @graph2 = {:title => "Amplitude des temps de trajets le soir", :subtitle => "#{@destination} >> #{@origin}",:xAxis => xAxis,:data => data}    
      data, xAxis = calc_chart_scatter(id, 6..10)
      @graph3 = {:title => "Répartition des temps de trajets le matin", :subtitle => "#{@origin} >> #{@destination}",:xAxis => xAxis,:data => data}
      data, xAxis = calc_chart_scatter(id, 16..20)
      @graph4 = {:title => "Répartition des temps de trajets le soir", :subtitle => "#{@destination} >> #{@origin}",:xAxis => xAxis,:data => data}
    rescue Exception => e
      message = "Exception for path #{id} in stats// e.message"
      location = "/stats/"
      Log.create(:message => message, :location => location)
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
    Log.create(:message => "Starting Run #{params[:now]}", :location => "/run/")
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
        date = DateTime.strptime(params[:now],"%Y-%m-%d_%H-%M")
        Result.create(:date => date, :interval => date.hour*100+date.minute , :minutes => min, :path_id => path.id, :is_morning => is_morning)
        
        rescue Exception => e
          message = "Exception for path #{path.id} in Run #{params[:now]}// e.message"
          location = "/run/"
          Log.create(:message => message, :location => location)
          logger.error "/run/ :" + e.message
        end
      end
      Log.create(:message => "Run #{params[:now]} Completed", :location => "/run/")
  end
  return "Done"
end


 