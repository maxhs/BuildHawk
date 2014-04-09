class AdminController < ApplicationController
	before_filter :authenticate_user!
	before_filter :find_user
	layout 'admin'	
	require 'stripe'

	def index
		@core_checklist = Checklist.where(:core => true).last
		@checklists = current_user.company.checklists
	end

	def show
		render :checklists
	end

	def edit_item

	end

	def users
		@company = @user.company
		unless @company.customer_token.nil? && current_user.uber_admin
			@users = current_user.company.users
			@subs = current_user.company.subs
			if request.xhr?
				respond_to do |format|
					format.js
				end
			end
		else
			@charges = @company.charges
		  	active_projects = @company.projects.where(:active => true).count
		  	@amount = active_projects * 1000 / 100
			redirect_to billing_admin_index_path
		end

	end

	def new_user
		@user = User.new
	end

	def create_user
		@user = current_user.company.users.create params[:user]
		@users = current_user.company.users
		@subs = current_user.company.subs
		if @user.save & request.xhr?
			@response_message = "User created".html_safe
			respond_to do |format|
				format.js { render :template => "admin/users" }
			end
		elsif @user.save
			flash[:notice] = "User created"
			redirect_to users_admin_index_path
		elsif request.xhr?
			@response_message = "Unable to create user. Please make sure the form is complete and the passwords match".html_safe
			respond_to do |format|
				format.js { render :template => "admin/incorrect" }
			end
		else
			flash[:notice] = "Unable to create user. Please make sure the form is complete and the passwords match."
			render :new_user
		end
	end

	def edit_user
		@user = User.find params[:id]
	end

	def update_user
		@user = User.find params[:id]
		@user.update_attributes params[:user]
		redirect_to users_admin_index_path
	end

	def new_sub
		@sub = Sub.new
	end

	def create_sub
		@sub = current_user.company.subs.create params[:sub]
		if @sub.save & request.xhr?
			respond_to do |format|
				format.js
			end
		elsif @sub.save
			flash[:notice] = "Sub created"
			redirect_to users_admin_index_path
		else
			flash[:notice] = "Unable to create sub. Please make sure the form is complete."
			redirect_to users_admin_index_path
		end
	end

	def edit_sub
		@sub = Sub.find params[:id]
	end

	def update_sub
		@sub = Sub.find params[:id]
		@sub.update_attributes params[:sub]
		redirect_to users_admin_index_path
	end

	def delete_user
		@user = User.find params[:id]
		@user.destroy
		redirect_to users_admin_index_path
	end

	def delete_sub
		@sub = Sub.find params[:id]
		@sub.destroy
		redirect_to users_admin_index_path
	end

	def reports
		@company = @user.company
		unless @company.customer_token.nil? && current_user.uber_admin
			@projects = current_user.company.projects
			if request.xhr?
				respond_to do |format|
					format.js
				end
			end
		else
			@charges = @company.charges
		  	active_projects = @company.projects.where(:active => true).count
		  	@amount = active_projects * 1000 / 100
			redirect_to billing_admin_index_path
		end
	end

	def checklists
		@checklists = current_user.company.checklists.flatten
	end

	def editor
		@checklist = Checklist.find params[:checklist_id]
		@project = @checklist.project
	end

	def create_template
		if Rails.env.production?
	    
			Resque.enqueue(CreateTemplate,params[:company_id])
			@response_message = "Creating checklist template. This may take a few minutes..."
			if request.xhr?
				respond_to do |format|
					format.js {render :template => "admin/background_template"}
				end
			else
				flash[:notice] = @response_message
				redirect_to checklists_admin_index_path
			end
		elsif Rails.env.development?
	      	puts "should be creating a template in development environment"
	    end
	end

	def new_project
		@company = @user.company
		unless @company.customer_token.nil? && current_user.uber_admin
			@project = Project.new
			@project.build_address
			@project.project_users.build
			@users = current_user.company.users
			@subs = current_user.company.subs
			if request.xhr?
				respond_to do |format|
					format.js
				end
			end
		else
			@charges = @company.charges
		  	active_projects = @company.projects.where(:active => true).count
		  	@amount = active_projects * 1000 / 100
			redirect_to billing_admin_index_path
		end
	end

	def billing
		@company = @user.company
		if @company.customer_token
			customer = Stripe::Customer.retrieve(@company.customer_token)
			invoices = Stripe::Invoice.all(
				:customer => customer.id,
			)

			@subtotal = 0
			@charges = invoices["data"].as_json
			@charges.map{|c| @subtotal += c["amount_due"]}
			puts "due: #{@subtotal} and charges: #{@charges}"
		end
	  	active_projects = @company.projects.where(:active => true).count
	  	@amount = active_projects * 1000 / 100
	end

	def edit_billing

	end

	def update_billing
		token = params[:stripeToken]
		if @company.customer_token
			customer = Stripe::Customer.retrieve(@company.customer_token)
			customer.card = token
			customer.save
		else
			customer = Stripe::Customer.create(
			  :card => token,
			  :plan => "normalhawk",
			  :email => @user.email
			)
		end
		puts "stripe customer id: #{customer.id}"
		@company.update_attribute :customer_token, customer.id

		redirect_to billing_admin_index_path
	end

	def project_groups
		@company = current_user.company
		@project_groups = @company.project_groups.where("id IS NOT NULL")
	end

	def find_user
		if params[:user_id].present?
			@user = User.where(:id => params[:user_id]).first
		else
			@user = current_user
		end
		@company = @user.company
	end

end