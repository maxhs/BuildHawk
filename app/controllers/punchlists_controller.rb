class PunchlistsController < ApplicationController
	before_filter :authenticate_user!
	def index
		@project = Project.find params[:project_id]
		@punchlists = @project.punchlists
	end

	def show

	end

	def export
		item_array = []
		params[:items].split(',').each do |i|
			puts "i: #{i}"
			item_array << PunchlistItem.find(i)
		end
		params[:names].each do |r|
			puts "r: #{r}"
			recipient = User.where(:full_name => r).first
			recipient = Sub.where(:name => r).first unless recipient
			PunchlistMailer.export(recipient.email, item_array, @project).deliver
		end
		params[:email].split(',').each do |e|
			PunchlistMailer.export(e, item_array, @project).deliver
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