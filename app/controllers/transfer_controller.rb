class TransferController < ApplicationController
	def index
		#variable contains the query from transfers DB
		@transfers = Transfer.select("section_id,section_name,sum(net) as net").group("section_id,section_name").order("section_id ASC")
		
		#array to contain the bubble graph
		a = []

		#fill the 'a' array with hashes(h) - each hash contains one section(bubble)
		@transfers.each do |section| 
			h = Hash.new()
			h["name"] = section.section_id
			h["size"] = section.net.abs
			a.push(h)
		end

		#creates json structure
		sectionhash = Hash.new()
		sectionhash["name"] = "stringush"
		sectionhash["children"] = a

		#creates json
		@jsontransfer = sectionhash.to_json
	end
end
