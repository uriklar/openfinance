class ProgramController < ApplicationController
	def show
		require 'open-uri'
		require 'json'
		@json = JSON.parse(open("http://budget.yeda.us/00?year=2005&depth=3").read)
		@breadcrumbs = {:section_id => nil}  
	end
end
