class ApplicationController < ActionController::Base
  protect_from_forgery

  	#method integreates between data from DB and from Open Budget and creates JSON for bubble chart
	def createJSON(level)
	#groups hash defines devision to colour groups
	groups = [	{:name => "very_high", :upper => 10000, :lower => 0.15},
				{:name => "high", :upper => 0.15, :lower => 0.05},
				{:name => "medium", :upper => 0.05, :lower => -0.05},   	
			   	{:name => "low", :upper => -0.05, :lower => -0.15},
			   	{:name => "very_low", :upper => -0.15, :lower => -1000}
			 ]

			 puts @obudget
			 puts @transfers

		#array that holds the final bubble data
		@section_array = []
		#array that holds section names from auto complete search bar
		@auto_complete = []

		@transfers.each_with_index do |section,index_section|
			#section_string = creating the section string for lookup in "Open Budget"
			section_string = getSectionString(section,level)
			puts section_string
			#check if section can't be found in open budget 
			#or if the section has a 0 budget	
			unless @obudget.find {|s| s["budget_id"] ==  section_string}.nil? ||  @obudget.find {|s| s["budget_id"] ==  section_string}["net_amount_allocated"] == 0
				puts "i found it"
				budget = @obudget.find {|s| s["budget_id"] == section_string}["net_amount_allocated"]   
				percent = section.net / budget
				#loop over group hash to find the correct group (low,medim,high)						
				groups.each_with_index do |group,index|
					flag = false
					if percent.between?(group[:lower],group[:upper])
						#once we found the group we create the bubble
						#budget size * 1000 since it is saved as /1000 in open budget
						bubble = {:id => index_section, :total_amount => budget*1000, 
								  :section_id => section.level_id,
						          :group => group[:name],
						          :value => budget*1000,
						          :percent => percent.round(3)*100,
						          :p_f => group[:p_from], :p_t => group[:p_to],
						          :section_name => section.level_name,
						          :start_year => 2009
						   		}
						@auto_complete.push({:label => section.level_name, :value => section.level_name, :id => index_section, :budget => bubble[:value], :percent =>bubble[:percent]})
						@section_array.push(bubble)
						flag = true
					end
					break if flag
				end	
			end
		end
	end

	def getSectionString(section,level)
		case level
		when 'section'
			return section.level_id.length > 1 ? "00" + section.level_id : "000" + section.level_id
		when 'field'
			return "00" + params[:id] + section.level_id
		when 'program'
			return "00" + params[:section_id] + params[:id] + section.level_id
		end
	end

end
