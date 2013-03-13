class ProgramController < ApplicationController
	def show
		@transfers =  Program.select("section_name,field_name,program_name,pniya_id,request_desc,net").where("section_id = ? AND field_id = ? AND program_id = ?", params[:section_id],params[:field_id],params[:id]).order("pniya_id")
		@breadcrumbs = { :section_id => params[:section_id],
	  					 :section_name => @transfers[0].section_name,
	  					 :field_id => params[:field_id],
	  					 :field_name => @transfers[0].field_name,
	  					 :program_id => params[:id],
	  					 :program_name => @transfers[0].program_name
	 				   }
	end
end
