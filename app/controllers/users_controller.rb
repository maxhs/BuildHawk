class UsersController < ApplicationController
	before_filter :authenticate_user!

	def new
		@user = User.new

		if request.xhr?
			respond_to do |format|
				format.js
			end
		else
			render :new
		end
	end

	def create
		@user = current_user.company.users.create params[:user]
		redirect_to projects_path
	end

	def index
		@users = current_user.company.users
	end

	def edit
		@user = current_user
	end

	def show
		@user = User.find params[:id]
	end

	def update
		@user = current_user
		@user.update_attributes params[:user] if params[:user] && current_user
		if @user.save
			sign_in(current_user, :bypass => true) if params[:user][:password].present? && params[:user][:password_confirmation].present?
			flash[:notice] = "Settings updated!"
			render :edit
		else
			redirect_to edit_user_path(@user)
			flash[:notice] = "Please make sure you've completed the form and that your password(s) are valid".html_safe
		end
	end
end
