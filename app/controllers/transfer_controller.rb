class TransferController < ApplicationController
	include ActionView::Helpers::NumberHelper
	def index
		require 'open-uri'
		require 'json'
		#variable that contains the query from transfers table
		@transfers = Transfer.select("section_id,section_name,sum(net) as net").group("section_id,section_name").order("section_id ASC")
		#variable that contains information from 'open budget'
		@obudget = JSON.parse(open("http://budget.yeda.us/00?year=2011&depth=1").read)
		@breadcrumbs = {:section_id => nil}  

		#the array to hold final bubble data
		section_array = []
		#groups hash defines devision to colour groups
		groups = [	{:name => "very_high", :upper => 10000, :lower => 0.15, :y_from => 750, :y_to => 800 , :x_from => 250 , :x_to => 650},
					{:name => "high", :upper => 0.15, :lower => 0.05, :y_from => 650, :y_to => 750 , :x_from => 150, :x_to => 750},
					{:name => "medium_high", :upper => 0.05, :lower => 0, :y_from => 400, :y_to => 650 , :x_from => 0, :x_to =>900},
					{:name => "medium_low", :upper => 0, :lower => -0.05, :y_from => 150, :y_to => 400 , :x_from => 0, :x_to => 900 },   	
				   	{:name => "low", :upper => -0.05, :lower => -0.15, :y_from => 50, :y_to => 150 , :x_from => 150, :x_to => 750},
				   	{:name => "very_low", :upper => -0.15, :lower => -1000, :y_from => 0, :y_to => 50 , :x_from => 250 , :x_to => 650}
				 ]
		@transfers.each_with_index do |section,index_section|
			#section_string = creating the section string for lookup in "Open Budget"
			section_string = "00" + section.section_id 
			#check if section can't be found in open budget 
			#or if the section has a 0 budget	
			unless @obudget.find {|s| s["budget_id"] ==  section_string}.nil? ||  @obudget.find {|s| s["budget_id"] ==  section_string}["net_amount_allocated"] == 0
				budget = @obudget.find {|s| s["budget_id"] == section_string}["net_amount_allocated"]   
				percent = section.net / budget
				#loop over group hash to find the correct group (low,medim,high)						
				groups.each_with_index do |group,index|
					flag = false
					if percent.between?(group[:lower],group[:upper])
						#once we found the group we create the bubble
						#budget size * 1000 since it is saved as /1000 in open budget
						bubble = {:id => index_section, :total_amount => budget*1000, :section_id => section.section_id,
						          :group => group[:name],
						          :value => budget*1000,
						          :percent => percent.round(3)*100,
						          :p_f => group[:p_from], :p_t => group[:p_to],
						          :section_name => section.section_name,
						          :start_year => 2009
						   		}
						section_array.push(bubble)
						flag = true
					end
					break if flag
				end	
			end
		end
		@json = section_array.to_json.html_safe 
		@path = "/section/"
	end

	def filter
		logger.info(params[:q])
		redirect_to :root
	end
end

