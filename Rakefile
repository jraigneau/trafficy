# -*- coding: utf-8 -*-
require 'sequel'

task :recreate_all => [:connectDB, :drop_results, :drop_paths, :create_paths, :create_results, :drop_logs, :create_logs]

task :connectDB do
  DB = Sequel.connect(ENV['DATABASE_URL'] || 'sqlite://trafficy-dev.db')
end

task :create_results => [:connectDB] do
  DB.create_table :results do
    primary_key :id
		DateTime      :date
		Integer   :minutes
    Integer   :is_morning
		foreign_key :path_id, :paths
		timestamp :created_at
		timestamp :updated_at
	end
end

task :drop_results => [:connectDB] do
  DB.drop_table :results
end

task :create_paths => [:connectDB] do
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
  DB.drop_table :paths
end

task :create_logs => [:connectDB] do
  DB.create_table :logs do
    primary_key :id
		String   :message
    DateTime :run_date
		foreign_key :path_id, :paths
		timestamp :created_at
		timestamp :updated_at
	end
end

task :drop_logs do
  DB.drop_table :logs
end