class ConnectController < ApplicationController

	def index
		if user_signed_in?
	    	project = Project.find params[:project_id] if params[:project_id]
			if current_user
				if project
					@items = WorklistItem.where(:assignee_id => @user.id).map{|t| t if t.worklist.project.id = project.id}.compact
				else
					@items = WorklistItem.where(:assignee_id => @user.id).map{|t| t if t.worklist.project.company.id != @user.company.id}.compact
				end
	      	end
		end
	end

end
