class UsersController < ApplicationController
	before_filter :authenticate_user!, :except => :preregister

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

	def preregister
		@user = User.create! params[:user]
		company = Company.where(:name => params[:company_name]).first_or_create if params[:company_name]
		if request.xhr?
			respond_to do |format|
				format.js
			end
		else
			redirect_to root_url
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
		@user.update_attributes params[:user] if params[:user]
		if @user.save
			sign_in(current_user, :bypass => true) if params[:user][:password].present? && params[:user][:password_confirmation].present?
			flash[:notice] = "Settings updated!"
			render :edit
		else
			redirect_to edit_user_path(@user)
			flash[:notice] = "Please make sure you've completed the form and that your password(s) are valid".html_safe
		end
	end

	def email_unsubscribe
		@user = User.find params[:id]
		@user.update_attribute :email_permissions, false
		flash[:notice] = "Successfully unsubscribed from all Verses emails".html_safe

		unless @user.save
			flash[:notice] = "Something went wrong. Please try unsubscribing again.".html_safe
		end

		render projects_path
	end
end
