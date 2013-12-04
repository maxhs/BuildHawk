class PunchlistsController < ApplicationController
	def index
		@project = Project.find params[:project_id]
		@punchlists = @project.punchlists
	end

	def show

	end
end