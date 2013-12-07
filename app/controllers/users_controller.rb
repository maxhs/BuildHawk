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
		@user.photos.build
	end

	def show
		@user = User.find params[:id]
	end

	def update
		@user = current_user
		@user.update_attributes params[:user] if params[:user] && current_user
		if @user.save!
			flash[:notice] = "Settings updated!"
		end
		render :edit
	end
end
