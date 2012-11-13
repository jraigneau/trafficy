require 'sequel'

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
    DB[:paths].insert(:origin => "14+Rue+de+Lorraine,+Asni%C3%A8res-sur-Seine", :destination => "Chemin+du+Bois+de+l'H%C3%B4tel+Dieu,+91130+Ris-Orangis", :created_at => Date.new, :updated_at => Date.new)
    DB[:paths].insert(:origin => "14+Rue+de+Lorraine,+Asni%C3%A8res-sur-Seine", :destination => "Ris-Orangis", :created_at => Date.new, :updated_at => Date.new)

end

task :drop_paths do
    DB = Sequel.sqlite("trafficy-dev.db")
    DB.drop_table :paths
end