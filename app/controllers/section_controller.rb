class SectionController < ApplicationController
	include ActionView::Helpers::NumberHelper
	def show
		require 'open-uri'
		require 'json'
		#variable that contains the query from transfers table
		@fields = Section.select("section_name,section_id,field_id,field_name,sum(net) as net").where("section_id = ?", params[:id]).group("field_id,field_name,section_name").order("field_id ASC")
		#variable that contains information from 'open budget'
		@obudget = JSON.parse(open("http://budget.yeda.us/00" + params[:id] +"?year=2011&depth=1").read)
		#html tag for breadcrums
		@breadcrumbs = {:section_id => params[:id],
					  :section_name => @fields[0].section_name,
					  :field_id => nil,
					 }  
		#the array to hold final bubble data
		field_array = []
		@auto_complete = []
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
			field_string = "00" + params[:id] + field.field_id
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
						bubble = {:id => index_field, :total_amount => budget*1000, :section_id => field.field_id,
						          :group => group[:name],
						          :value => budget*1000,
						          :percent => percent.round(3)*100,
						          :p_f => group[:p_from], :p_t => group[:p_to],
						          :section_name => field.field_name,
						          :start_year => 2009
						   		}
						@auto_complete.push({:label => field.field_name, :value => field.field_name, :id => index_field, :budget => bubble[:value], :percent =>bubble[:percent]})          
						field_array.push(bubble)
						flag = true
					end
					break if flag
				end	
			end
		end
		@json = field_array.to_json.html_safe 
		@path = "/field/"
		@auto_complete = @auto_complete.to_json.html_safe
	end	


	def show_bar
		#field names for x axis
		categories_temp = []
		a = []
		#values for y axis
		data = []
		section = Section.select("section_name,field_id,field_name,sum(net) as net").where("section_id = ?", params[:id]).group("field_id,field_name").order("field_id ASC")
		section.each do |field|
			categories_temp.push(field.field_name)
			data.push(field.net.to_f)
			@title = field.section_name
		end
		@categories = categories_temp.to_json.html_safe
		h = {:name => "sum", :data => data}
		a.push(h)
		@series = a.to_json.html_safe

	end
end
