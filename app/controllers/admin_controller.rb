class AdminController < ApplicationController

	def import_checklist
		Checklist.import(params[:file])
	end
end