class TransferController < ApplicationController
	include ActionView::Helpers::NumberHelper
	def index
		require 'open-uri'
		require 'json'
		#variable that contains the query from transfers table
		@transfers = Transfer.select("section_id,section_name,sum(net) as net").group("section_id,section_name").order("section_id ASC")
		#variable that contains information from 'open budget'
		@obudget = JSON.parse(open("http://budget.yeda.us/00?year=2011&depth=1").read)
		#the array to hold final bubble data
		section_array = []
		#groups hash defines devision to colour groups
		groups = [	{:name => "high", :upper => 10000, :lower => 0.05, :p_from => 0.66, :p_to => 1 },   	
				   	{:name => "medium", :upper => 0.05, :lower => -0.05, :p_from => 0.33, :p_to => 0.66},
				   	{:name => "low", :upper => -0.05, :lower => -1000, :p_from => 0, :p_to => 0.33}
				 ]
		@transfers.each_with_index do |section,index_section|
			#section_string = creating the section string for lookup in "Open Budget"
			#@@@ more elegant solution?
			section_string = section.section_id.length < 2  ? "000" + section.section_id : "00" + section.section_id 
			#check if section can't be found in open budget 
			#or if the section has a 0 budget	
			unless @obudget.find {|s| s["budget_id"] ==  section_string}.nil? ||  @obudget.find {|s| s["budget_id"] ==  section_string}["net_amount_allocated"] == 0
				budget = @obudget.find {|s| s["budget_id"] == section_string}["net_amount_allocated"]   
				percent = section.net / budget
				@sectionid = section.section_id
				@budget1 = budget 
				#loop over group hash to find the correct group (low,medim,high)						
				groups.each_with_index do |group,index|
					flag = false
					if percent.between?(group[:lower],group[:upper])
						#once we found the group we create the bubble
						#budget size * 1000 since it is saved as /1000 in open budget
						#number_with_delimiter(budget*1000, :delimiter => ',')
						bubble = {:id => index_section, :total_amount => budget*1000, :grant_title => section.section_id,
						          :organization => "org_a", :group => group[:name],
						          :value => number_with_delimiter(budget*1000, :delimiter => ','),
						          :start_year => (percent.round(3)*100).to_s + "%",
						          :p_f => group[:p_from], :p_t => group[:p_to]}
						          
						section_array.push(bubble)
						flag = true
					end
					break if flag
				end	
			end
		end
		@json = section_array.to_json.html_safe 
	end
end