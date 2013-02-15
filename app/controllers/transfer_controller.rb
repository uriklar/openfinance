class TransferController < ApplicationController
	def index
		#@transfers = Transfer.select("transfer_id,section_id,sum(net) as net").group("transfer_id,section_id").having("sum(net) <> ?",0).order("transfer_id ASC")
		@transfers = Transfer.select("section_id,section_name,sum(net) as net").group("section_id,section_name").order("section_id ASC")
		
		a = []

		@transfers.each do |section| 
			h = Hash.new()
			h["name"] = section.section_id
			h["size"] = section.net.abs
			a.push(h)
		end

		sectionhash = Hash.new()
		sectionhash["name"] = "stringush"
		sectionhash["children"] = a
		@jsonex = sectionhash.to_json

	end
end
