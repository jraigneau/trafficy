Sequel.migration do
	def up
		create_table :paths do
			primary_key :id
			String  :origin
			String  :destination
			Date    :morning_interval
			Date 		:evening_interval
			timestamp :created_at
			timestamp :updated_at
		end
	end

	def down
		drop_table :paths
	end
end