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
		@transfers = Transfer.select("section_id as level_id,section_name as level_name,sum(net) as net").where("year = ?",session[:year]).group("section_id,section_name").order("section_id ASC")
		#variable that contains information from 'open budget'
		@obudget = JSON.parse(open("http://budget.yeda.us/00?year="+ session[:year]+ "&depth=1").read)
		@breadcrumbs = {:section_id => nil}  

		
		createJSON('section')

		@auto_complete = @auto_complete.to_json.html_safe
		@json = @section_array.to_json.html_safe

		@path = "/section/"
	end

	def filter
		session[:year] = params[:year]
		redirect_to :root
	end
end

