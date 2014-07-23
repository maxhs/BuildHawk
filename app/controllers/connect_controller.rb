class ConnectController < ApplicationController

	def index
		if user_signed_in?
	    	project = Project.find params[:project_id] if params[:project_id]
			if current_user	
				@items = current_user.connect_items
	      	end
		end
	end

end
