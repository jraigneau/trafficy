# -*- coding: utf-8 -*-
require 'sequel'

## Configurations 
enable :sessions

configure :development do
	DB = Sequel.sqlite('trafficy-dev.db')
	set :port, ENV['PORT']
	set :bind, ENV['IP']
end

configure :production do
	DB = Sequel.connect(ENV['HEROKU_POSTGRESQL_BRONZE_URL'])
end

set :root, File.dirname(__FILE__)
set :views, "#{File.dirname(__FILE__)}/views"
set :public_folder, "#{File.dirname(__FILE__)}/public"
set :sessions, true

Sequel::Model.plugin :timestamps

require './models'

