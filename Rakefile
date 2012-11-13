# -*- coding: utf-8 -*-
require 'sequel'

task :recreate_all => [:drop_results, :drop_paths, :create_paths, :create_results]

task :create_results do
    DB = Sequel.sqlite("trafficy-dev.db")
    
    DB.create_table :results do
    	primary_key :id
		Date      :date
		Integer   :minutes
        Integer   :is_morning
		foreign_key :path_id, :paths
		timestamp :created_at
		timestamp :updated_at
	end
end

task :drop_results do
    DB = Sequel.sqlite("trafficy-dev.db")
    DB.drop_table :results
end

task :create_paths do
    DB = Sequel.sqlite("trafficy-dev.db")
	DB.create_table :paths do
		primary_key :id
		String  :origin
		String  :destination
		timestamp :created_at
		timestamp :updated_at
	end
    DB[:paths].insert(:origin => "14 Rue de Lorraine, Asnières-sur-Seine", :destination => "Chemin du Bois de l'Hôtel Dieu, 91130 Ris-Orangis")
    DB[:paths].insert(:origin => "14 Rue de Lorraine, Asnières-sur-Seine", :destination => "26 rue de la rochefoucauld, Boulogne-Billancourt")

end

task :drop_paths do
    DB = Sequel.sqlite("trafficy-dev.db")
    DB.drop_table :paths
end