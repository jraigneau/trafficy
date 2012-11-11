Sequel.migration do
	def up
		create_table :results do
			primary_key :id
			Date      :date
			Integer   :minutes
			foreign_key :path_id, :paths
			timestamp :created_at
			timestamp :updated_at
		end
		create_table :paths do
			primary_key :id
			String  :origin
			String  :destination
			Boolean	:type #true = evening 
			timestamp :created_at
			timestamp :updated_at
		end

	end

	def down
		drop_table :results
		drop_table :paths
	end
end