class Path < Sequel::Model
		one_to_many :results
end

class Result < Sequel::Model
		many_to_one :path
end
