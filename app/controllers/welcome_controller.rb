class WelcomeController < ApplicationController
  def index
  			Transfer.where(:section_id => "section_id").destroy_all

  	@transfers = Transfer.all
  	require 'open-uri'
	require 'json'
	#@result = JSON.parse(open("http://budget.yeda.us/00?year=2011&depth=1").read)
  end
end
