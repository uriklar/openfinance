class FieldController < ApplicationController
	include ActionView::Helpers::NumberHelper
	def show
		require 'open-uri'
		require 'json'
		#variable that contains the query from transfers table
		@fields =  Field.select("section_name,field_name,program_id,program_name,sum(net) as net").where("section_id = ? AND field_id = ?", params[:section_id],params[:id]).group("field_name,field_id,program_id,program_name").order("program_id ASC")
		#variable that contains information from 'open budget'
		@obudget = JSON.parse(open("http://budget.yeda.us/00" + params[:section_id] + params[:id] + "?year=2011&depth=1").read)
		
		@breadcrumbs = {:section_id => params[:section_id],
			  :section_name => @fields[0].section_name,
			  :field_id => params[:id],
			  :field_name => @fields[0].field_name,
			  :program_id => nil
			 } 

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
						          :value => budget*1000,
						          :percent => percent.round(3)*100,
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
		@path = "/program/"
		@transfers = []
	end	

	def get_transfers
		transfers = Field.select("section_name,field_name,program_name,pniya_id,request_desc,net").where("section_id = ? AND field_id = ? AND program_id = ?", params[:section_id],params[:id],params[:program_id]).order("pniya_id")
		logger.info(params)
		logger.info(transfers.size)
		@json = transfers.to_json
		transfers.each do |t|
		logger.info(t.program_name)
		end
		respond_to do |format|
   			 format.json { render json: @json }
		end
	end		
end
