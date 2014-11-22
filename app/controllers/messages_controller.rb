class MessagesController < AppController
	before_filter :authenticate_user!

	def index
		@messages = current_user.messages 
	end

	def new
		@message = Message.new
		@users = current_user.company.users
		@projects = current_user.company.projects
		if request.xhr?
			respond_to do |format|
				format.js
			end
		else
			redirect_to projects_path
		end
	end

	def create
		@message = Message.create params[:message]
		if request.xhr?
			respond_to do |format|
				format.js
			end
		else
			redirect_to projects_path
		end
	end

	def edit
		@message = Message.find params[:id]
		@users = current_user.company.users
		@projects = current_user.company.projects
		if request.xhr?
			respond_to do |format|
				format.js
			end
		else
			redirect_to projects_path
		end
	end

	def message_user
		message = Message.find params[:id]
		message_user = MessageUser.where(message_id: message.id, user_id: current_user.id).first
		if message_user
			@message_id = message.id 
			message_user.destroy
			if request.xhr?
				respond_to do |format|
					format.js
				end
			else
				redirect_to root_url, notice:"Sorry, but something went wrong while trying to hide this message."
			end

		else
			if request.xhr?
				respond_to do |format|
					format.js
				end
			else
				redirect_to root_url, notice:"Sorry, but something went wrong while trying to hide this message."
			end
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
