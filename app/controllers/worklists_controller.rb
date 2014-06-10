class WorklistsController < ApplicationController
	before_filter :authenticate_user!
	def index
		@project = Project.find params[:project_id]
		@worklists = @project.worklists
	end

	def show

	end

	def export
		@project = Project.find params[:project_id]
		item_array = []
		params[:items].split(',').each do |i|
			item_array << WorklistItem.find(i)
		end
		params[:names].each do |r|
			recipient = User.where(:full_name => r).first
			recipient = Sub.where(:name => r).first unless recipient
			WorklistMailer.export(recipient.email, item_array, @project).deliver
		end
		params[:email].split(',').each do |e|
			WorklistMailer.export(e, item_array, @project).deliver
		end

		if request.xhr?
			respond_to do |format|
				format.js
			end
		else
			render "projects/worklist"
		end
	end
end