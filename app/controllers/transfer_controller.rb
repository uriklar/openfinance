class TransferController < ApplicationController
	include ActionView::Helpers::NumberHelper
	def index
		require 'open-uri'
		require 'json'

		#just for now!
		if session[:year].nil?
			session[:year] = "2011"
		end

		#variable that contains the query from transfers table
		@transfers = Transfer.select("section_id,section_name,sum(net) as net").where("year = ?",session[:year]).group("section_id,section_name").order("section_id ASC")
		#variable that contains information from 'open budget'
		@obudget = JSON.parse(open("http://budget.yeda.us/00?year="+ session[:year]+ "&depth=1").read)
		@breadcrumbs = {:section_id => nil}  

		#the array to hold final bubble data
		section_array = []
		@auto_complete = []
		#groups hash defines devision to colour groups
		groups = [	{:name => "very_high", :upper => 10000, :lower => 0.15},
					{:name => "high", :upper => 0.15, :lower => 0.05},
					{:name => "medium", :upper => 0.05, :lower => -0.05},   	
				   	{:name => "low", :upper => -0.05, :lower => -0.15},
				   	{:name => "very_low", :upper => -0.15, :lower => -1000}
				 ]
		@transfers.each_with_index do |section,index_section|
			#section_string = creating the section string for lookup in "Open Budget"
			section_string =section.section_id.length > 1 ? "00" + section.section_id : "000" + section.section_id
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
						@auto_complete.push({:label => section.section_name, :value => section.section_name, :id => index_section, :budget => bubble[:value], :percent =>bubble[:percent]})
						section_array.push(bubble)
						flag = true
					end
					break if flag
				end	
			end
		end
		@auto_complete = @auto_complete.to_json.html_safe
		@json = section_array.to_json.html_safe

		@path = "/section/"
	end

	def filter
		session[:year] = params[:year]
		logger.info(params[:year])
		redirect_to :root
	end
end

