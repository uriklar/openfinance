class FieldController < ApplicationController
	include ActionView::Helpers::NumberHelper
	def show
		require 'open-uri'
		require 'json'
		#variable that contains the query from transfers table
		@transfers =  Field.select("section_name,field_name,program_id as level_id,program_name as level_name,sum(net) as net").where("section_id = ? AND field_id = ?", params[:section_id],params[:id]).group("field_name,field_id,program_id,program_name").order("program_id ASC")
		#variable that contains information from 'open budget'
		@obudget = JSON.parse(open("http://budget.yeda.us/00" + params[:section_id] + params[:id] + "?year=2011&depth=1").read)
		@breadcrumbs = {
				:section_id => params[:section_id],
			  	:section_name => @transfers[0].section_name,
			  	:field_id => params[:id],
			  	:field_name => @transfers[0].field_name,
			  	:program_id => nil
			 			} 
		createJSON('program')

		@json = @section_array.to_json.html_safe 
		@path = "/program/"
		@transfers = []
		@auto_complete = @auto_complete.to_json.html_safe 
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
