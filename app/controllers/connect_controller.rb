class ConnectController < ApplicationController

	def index
		# unless user_signed_in?
		# 	if params[:email]
		# 		current_user = User.where(:email => params[:email]).first
		# 		current_user = ConnectUser.where(:email => params[:email]).first
		# 	end
		# end

		
			project = Project.where(:id => params[:project_id]).first if params[:project_id]
			if current_user
				if project
					@items = current_user.connect_items(project)
				else
					@items = current_user.connect_items(nil)
				end
				@companies = @items.map{|t| t.worklist.project.company}.uniq
	      	end
	    
	end
end
