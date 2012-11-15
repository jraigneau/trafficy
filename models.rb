# -*- coding: utf-8 -*-
class Path < Sequel::Model	
	one_to_many :results
end

class Result < Sequel::Model	 
	many_to_one :path
end

class Log < Sequel::Model
	many_to_one :path
end
