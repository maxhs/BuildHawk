class UsersController < AppController
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

	def create
		@user = current_user.company.users.create params[:user]
		@company = current_user.company
		@users = @company.users
		@subcontractors = @company.company_subs
		@admin = true if params[:admin] && current_user.any_admin?
		if @user.errors.any?
			render :new_user, notice:"#{@user.errors.full_messages.first}"
		elsif @user.save & request.xhr?
			respond_to do |format|
				format.js
			end
		elsif @user.save
			redirect_to users_admin_index_path, notice: "User created"
		elsif request.xhr?
			@response_message = "Unable to create user. Please make sure the form is complete and the passwords match.".html_safe
			respond_to do |format|
				format.js { render :template => "admin/incorrect" }
			end
		else
			render :new_user, notice:"Unable to create user. Please make sure the form is complete and the passwords match."
		end
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
		if params[:user][:phone]
			params[:user][:phone] = @user.clean_phone(params[:user][:phone])	
		else
			params[:user][:phone] = nil
		end
		@user.update_attributes params[:user]
		
		if @user.save
			sign_in(@user, :bypass => true) if params[:user][:password].present? && params[:user][:password_confirmation].present?
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

	def basic
		@user = User.find params[:id]
		puts "deactivating #{@user.full_name}"
	end
end
