class ConnectController < ApplicationController

	def index
		if user_signed_in?
	    	project = Project.where(:id => params[:project_id]).first if params[:project_id]
			if current_user
				if project
					@items = current_user.connect_items(project)
					@companies = @items.map{|t| t.worklist.project.company}
				else
					@items = current_user.connect_items(nil)
					@companies = @items.map{|t| t.worklist.project.company}
				end
	      	end
		end
	end

end
