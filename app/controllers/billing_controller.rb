class BillingController < AppController
	before_filter :find_user
	layout 'print', only: :invoice

	def index
		@cards = @company.cards.where("card_id IS NOT NULL")
		@stripe_key = Rails.configuration.stripe[:publishable_key]
		@active_card = @company.cards.where(:active => true).first 
		@month = Time.now.to_datetime
		@pro_users = @user.company.billing_days_for(@month).map{|day| day.project_user.user}.compact.uniq

		if @company.customer_id
			customer = Stripe::Customer.retrieve(@company.customer_id)
			invs = Stripe::Invoice.all(
				:customer => customer.id,
			)

			@subtotal = 0
			@invoices = invs["data"].as_json
			@invoices.map{|c| @subtotal += c["amount_due"]}
		else 
			@card = @company.cards.new
		end
	  	active_projects = @company.projects.where(:active => true).count
	  	@amount = active_projects * 1000 / 100
	rescue Stripe::InvalidRequestError => e
		flash[:alert] = "Something went wrong while trying to fetch your billing information."
	 	redirect_to admin_index_path
	end

	def new_card
		@stripe_key = Rails.configuration.stripe[:publishable_key]
		@card = @company.cards.new
	end

	def create
		token = params[:stripeToken]
		if @company.customer_id 
			customer = Stripe::Customer.retrieve(@company.customer_id)
			card = customer.cards.create card: token
			customer.save
		else
			customer = Stripe::Customer.create(
			  	:card => token,
			  	:plan => "monthly_standard",
			  	:description => @company.name,
			  	:email => @user.email
			)
			@user.company.update_attribute :customer_id, customer.id
			card = customer.cards.data.first
		end
		
		@card = @user.company.cards.create :card_id => card.id, :last4 => card.last4, :exp_month => card.exp_month, :exp_year => card.exp_year, :brand => card.brand
		@card.update_attribute :active, true if @company.cards.count == 1
		redirect_to billing_index_path
	rescue Stripe::InvalidRequestError => e
		@error_message = e.message
		if request.xhr?
			respond_to do |format|
				format.js {render template:"billing/errors"}
			end
		else
			flash[:error] = e.message
	 		redirect_to billing_index_path
		end
		puts "rescquing invalid request #{e.message}"
	rescue Stripe::CardError => e
		puts "rescquing card error #{e}"
		flash[:error] = e.message
	 	redirect_to billing_index_path
	end

	def invoice
		@invoice = Stripe::Invoice.retrieve(params[:invoice_id])
		if @invoice
			@data = @invoice["lines"]["data"].first
			@month = Time.at(@invoice["period_start"]).to_datetime
			@pro_users = @user.company.billing_days_for(@month).map{|day| day.project_user.user}.compact.uniq
			if @invoice["discount"]
			 	discount = @invoice["discount"]["coupon"]
			 	@credit_name = discount["id"]
			 	if discount["amount_off"]
			 		@credit = discount["amount_off"]
			 	else
			 		@credit = @invoice["subtotal"] * discount["percent_off"]/100
			 	end
			end
			puts "invoice: #{@invoice} for month: #{@month.strftime("%b")}"
		else
			flash[:alert] = "Something went wrong while trying to view this invoice."
			redirect_to billing_index_path
		end
		@company = @user.company
		@billing_days = @user.company.billing_days_for(@month)
		@pro_users = @billing_days.map{|day| day.project_user.user}.compact.uniq

		start_of_month = @month.beginning_of_month
		puts "start of month: #{start_of_month}"
		end_of_month = @month.end_of_month
		puts "end of month: #{end_of_month}"

		live_projects = @user.company.projects.where(active:true)
		if live_projects.count == 1
			@live_projects_count_string = "1 Live Project"
		else
			@live_projects_count_string = "#{live_projects.count} Live Projects"
		end

		@documents = @user.company.photos.where("created_at > ? and created_at < ?",start_of_month, end_of_month)
		@tasks = @user.company.projects.map(&:tasklists).flatten.map{|t|t.tasks.where("created_at > ? and created_at < ?",start_of_month, end_of_month)}.compact
		@reports = @user.company.projects.map{|p|p.reports.where("created_at > ? and created_at < ?",start_of_month, end_of_month)}
		@items = @user.company.projects.map(&:checklist).compact.map{|c|c.checklist_items.where("completed_date > ? and completed_date < ?",start_of_month, end_of_month)}.compact
		puts "items: #{@items}"
	end

	def summary
		@month = Time.now.to_datetime
		@pro_users = @user.company.billing_days_for(@month).map{|day| day.project_user.user}.compact.uniq
		puts "invoice: #{@invoice} for month: #{@month.strftime("%b")}"
	end

	def edit_card
		@card = Card.where(:id => params[:card_id]).first
		if @card
			@stripe_key = Rails.configuration.stripe[:publishable_key]
		else
			redirect_to billing_index_path
		end
	end

	def edit
		
	end

	def destroy
		card = Card.find params[:id]
		customer = Stripe::Customer.retrieve(@company.customer_id)
		stripe_card = customer.cards.retrieve(card.card_id)
		stripe_card.delete if stripe_card 
		card.destroy
		redirect_to billing_index_path
	end

	def update
		@card = Card.find params[:id]
		@company.cards.map{|c| c.update_attribute :active, false}
		@card.update_attributes params[:card]
		if params[:card][:active] == "1"
			customer = Stripe::Customer.retrieve(@company.customer_id)
			customer.default_card = @card.card_id
			customer.save
		end
		redirect_to billing_index_path
	
	rescue Stripe::CardError => e
		 flash[:error] = e.message
		 redirect_to billing_index_path
	end

	def pay
		invoice = Stripe::Invoice.retrieve("in_4ct8hzEmBRI9bv")
		invoice.pay
	rescue Stripe::InvalidRequestError => e
		puts "error? #{e.message}"
	  	flash[:alert] = e.message
		redirect_to billing_index_path
	end

	private

	# def invoice
	# 	invoice = Stripe::Invoice.create(customer: @user.company.customer_id)
	# end

	def find_user
		unless current_user.any_admin?
			flash[:alert] = "Sorry, you don't have access to that section.".html_safe
			redirect_to projects_path
		else
			if params[:user_id].present?
				@user = User.where(:id => params[:user_id]).first
			else
				@user = current_user
			end
			@projects = @user.project_users.where(:hidden => false).map(&:project).compact.uniq
			@company = @user.company
		end
	end

end
