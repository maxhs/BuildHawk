class MessagesController < AppController
	before_filter :authenticate_user!

	def index
		@messages = current_user.messages 
	end

	def new
		@message = Message.new
		@users = current_user.company.users
		@projects = current_user.company.projects
	end

	def create
		@message = Message.create params[:message]
		@messages = current_user.messages
		if request.xhr?
			respond_to do |format|
				format.js {render template:"projects/index"}
			end
		else
			redirect_to projects_path
		end
	end

	def destroy
		message = Message.find params[:id]
		if message.destroy
			if request.xhr?
				respond_to do |format|
					format.js
				end
			else
				flash[:notice] = "Message removed"
				redirect_to root_url
			end

		else

		end
	end
end
