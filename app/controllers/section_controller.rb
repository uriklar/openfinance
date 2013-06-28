class SectionController < ApplicationController
	include ActionView::Helpers::NumberHelper
	def show
		require 'open-uri'
		require 'json'
		#variable that contains the query from transfers table
		@transfers = Section.select("section_name,section_id,field_id as level_id,field_name as level_name,sum(net) as net").where("section_id = ?", params[:id]).group("field_id").order("field_id ASC")
		#variable that contains information from 'open budget'
		@obudget = JSON.parse(open("http://budget.yeda.us/00" + params[:id] +"?year=2011&depth=1").read)

		@breadcrumbs = {:section_id => params[:id],
					  :section_name => @transfers[0].section_name,
					  :field_id => nil
					 }  

		createJSON('field')

		@json = @section_array.to_json.html_safe 
		@path = "/field/"
		@auto_complete = @auto_complete.to_json.html_safe
	end	

end
