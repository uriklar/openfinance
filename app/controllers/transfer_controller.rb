class TransferController < ApplicationController
	def index
		#@transfers = Transfer.select("transfer_id,section_id,sum(net) as net").group("transfer_id,section_id").having("sum(net) <> ?",0).order("transfer_id ASC")
	end

	def flare
		respond_to do |format|
    		format.json { render :json => { 1 => "First", 2 => "Second"} }
    	end
	end
end
