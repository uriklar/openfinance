class FieldController < ApplicationController
	include ActionView::Helpers::NumberHelper
	def show
		require 'open-uri'
		require 'json'
		#variable that contains the query from transfers table
		@fields =  Field.select("field_name,program_id,program_name,sum(net) as net").where("section_id = ? AND field_id = ?", params[:section_id],params[:id]).group("field_name,field_id,program_id,program_name").order("program_id ASC")
		#variable that contains information from 'open budget'
		@obudget = JSON.parse(open("http://budget.yeda.us/00" + params[:section_id] + params[:id] + "?year=2011&depth=1").read)
		#the array to hold final bubble data
		field_array = []
		#groups hash defines devision to colour groups
		groups = [	{:name => "very_high", :upper => 10000, :lower => 0.15, :p_from => 0.833333333, :p_to => 1},
					{:name => "high", :upper => 0.15, :lower => 0.05, :p_from => 0.666666667, :p_to => 0.833333333},
					{:name => "medium_high", :upper => 0.05, :lower => 0, :p_from => 0.5, :p_to => 0.666666667},
					{:name => "medium_low", :upper => 0, :lower => -0.05, :p_from => 0.333333333, :p_to => 0.5 },   	
				   	{:name => "low", :upper => -0.05, :lower => -0.15, :p_from => 0.166666667 , :p_to => 0.333333333},
				   	{:name => "very_low", :upper => -0.15, :lower => -1000, :p_from => 0, :p_to => 0.166666667}
				 ]	
	
		@fields.each_with_index do |field,index_field|
			#field_string = creating the section string for lookup in "Open Budget"
			field_string = "00" + params[:section_id] + params[:id] + field.program_id
			#check if section can't be found in open budget 
			#or if the section has a 0 budget	
			unless @obudget.find {|s| s["budget_id"] ==  field_string}.nil? ||  @obudget.find {|s| s["budget_id"] ==  field_string}["net_amount_allocated"] == 0
				#@@@constider calling find one time and using the result in the condition and here
				budget = @obudget.find {|s| s["budget_id"] == field_string}["net_amount_allocated"]   
				percent = field.net / budget
				#loop over group hash to find the correct group (low,medim,high)						
				groups.each_with_index do |group,index|
					flag = false
					if percent.between?(group[:lower],group[:upper])
						#once we found the group we create the bubble
						#budget size * 1000 since it is saved as /1000 in open budget
						bubble = {:id => index_field, :total_amount => budget*1000, :section_id => field.program_id,
						          :group => group[:name],
						          :value => number_with_delimiter(budget*1000, :delimiter => ','),
						          :percent => (percent.round(3)*100).to_s + "%",
						          :p_f => group[:p_from], :p_t => group[:p_to],
						          :section_name => field.program_name,
						          :start_year => 2009
						   		}		 
						field_array.push(bubble)
						flag = true
					end
					break if flag
				end	
			end
		end
		@json = field_array.to_json.html_safe 
		@path = "/field/"
	end	

	def show_bar
		#program names for x axis
		categories_temp = []
		a = []
		#values for y axis
		data = []
		field = Field.select("field_name,program_id,program_name,sum(net) as net").where("field_id = ?", params[:id]).group("program_id,program_name").order("program_id ASC")
		field.each do |program|
			categories_temp.push(program.program_name)
			data.push(program.net.to_f)
			@title = program.field_name
		end
		@categories = categories_temp.to_json.html_safe
		h = {:name => "sum", :data => data}
		a.push(h)
		@series = a.to_json.html_safe
	end
end