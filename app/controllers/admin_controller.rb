class AdminController < ApplicationController
	before_filter :authenticate_user!
	before_filter :find_user
	require 'stripe'

	def index
		uber_checklists
		@checklists = @user.company.checklists.where(:core => true)
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
		@users = current_user.company.users
		@subs = current_user.company.subs
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

	def safety_topics
		@company = @user.company
		@safety_topics = @company.safety_topics
		@uber_topics = SafetyTopic.where("company_id IS NULL and core = ?",true)
		if request.xhr?
			respond_to do |format|
				format.js
			end
		else
			render :safety_topics
		end
	end

	def clone_topic
		topic = SafetyTopic.find params[:id]
		@safety_topic = SafetyTopic.create :title => topic.title, :info => topic.info, :company_id => @user.company.id
		if request.xhr?
			respond_to do |format|
				format.js
			end
		else
			redirect_to safety_topics_admin_index_path
		end
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
		uber_checklists
		@checklists = @user.company.checklists.where(:core => true).flatten
	end

	def editor
		@checklist = Checklist.find params[:checklist_id]
		@project = @checklist.project
	end

	def create_blank_template
		@checklist = Checklist.create :company_id => @user.company.id, :name => params[:name], :core => true
		category = @checklist.categories.create :name => "Phase"
		subcategory = category.subcategories.create :name => "Category"
		subcategory.checklist_items.create :body => "First Item"
		if request.xhr?
			respond_to do |format|
				format.js { render template: "admin/create_template"}
			end
		else
			uber_checklists
			@checklists = @user.company.checklists.where(:core => true).flatten
			render :checklists
		end
	end

	def create_template
		list = Checklist.find params[:checklist_id]
		@checklist = list.duplicate
		@checklist.save
		@checklist.update_attribute :company_id, @company.id
		puts "is it getting the new company id? #{@checklist.company.id}"
		
		@checklists = @user.company.checklists.where(:core => true).flatten
		if request.xhr?
			respond_to do |format|
				format.js
			end
		else
			uber_checklists
			render :checklists
		end
		
		# if Rails.env.production?
		# 	Resque.enqueue(CreateTemplate,params[:company_id])
		# 	@response_message = "Creating checklist template. This may take a few minutes..."
		# 	if request.xhr?
		# 		respond_to do |format|
		# 			format.js {render :template => "admin/background_template"}
		# 		end
		# 	else
		# 		flash[:notice] = @response_message
		# 		redirect_to checklists_admin_index_path
		# 	end
		# elsif Rails.env.development?
	 #      	checklists = Checklist.where("core = ? and name = ? and company_id IS NULL and project_id IS NULL",true,params[:name])
	 #      	if checklists && checklists.count > 0	
	 #      		@checklist = checklists.first
	 #      		puts "Found core checklist, #{checklists.count-1} remaining. Checklist id: #{@checklist.id}"
	 #      		@checklist.uber_fifo
	 #      		@checklist.company_id = @user.company.id
	 #      		@checklist.save!
	 #      		puts "found a checklist. should be doing core fifo now for company id: #{@user.company.id}"
	 #      		@checklist.core_fifo
	 #      	end
	 #    end
	end

	def remove_template
		@checklist = Checklist.find params[:id]
		@checklist_id = params[:id]
		@checklist.destroy
	end

	def new_project
		@company = @user.company
		unless @company.customer_token.nil? && current_user.uber_admin
			@project = Project.new
			@project.build_address
			@project.project_users.build
			@users = current_user.company.users
			@subs = current_user.company.subs
			@checklists = @user.company.checklists.where(:core => true)
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

	protected

	def uber_checklists
		names = Checklist.where("core = ? and company_id IS NULL",true).map(&:name).compact.uniq
		@uber_checklists = [] 
		names.each do |n|
			@uber_checklists << Checklist.where(:core => true, :name => n, :project_id => nil).first if n && n.length > 0
		end
	end

	def find_user
		if params[:user_id].present?
			@user = User.where(:id => params[:user_id]).first
		else
			@user = current_user
		end
		@projects = @user.project_users.where(:archived => false).map(&:project).compact.uniq
		@company = @user.company
	end
end