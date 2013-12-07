class CompaniesController < ApplicationController
	before_filter :authenticate_user!, :except => :create

	def index
		
	end

	def create
		@company = Company.create params[:company]
	end
end
