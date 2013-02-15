class WelcomeController < ApplicationController
  def index
  	@transfers = Transfer.all
  	#require 'open-uri'
	#require 'json'
	#@result = JSON.parse(open("http://budget.yeda.us/00?year=2012&depth=3").read)
  end
end
