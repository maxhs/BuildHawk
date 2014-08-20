class BillingController < ApplicationController

	before_filter :find_user

	def index
		@company = @user.company
		@cards = @company.cards
		@stripe_key = Rails.configuration.stripe[:publishable_key]
		@active_card = @company.cards.where(:active => true).first 
		if @active_card && @company.customer_id
			customer = Stripe::Customer.retrieve(@company.customer_id)
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

	def edit
		@card = Card.find params[:id]
		@stripe_key = Rails.configuration.stripe[:publishable_key]
	end

	def update_billing
		token = params[:stripeToken]
		if @company.customer_id 
			customer = Stripe::Customer.retrieve(@company.customer_id)
			customer.card = token
			customer.save
			puts "already had a customer"
		else
			customer = Stripe::Customer.create(
			  	:card => token,
			  	:plan => "monthly_standard",
			  	:email => @user.email
			)
			puts "had to create a new customer"
		end
		card_data = customer.cards.data.first
		puts "card_data: #{card_data}"
		@user.company.update_attribute :customer_id, customer.id
		@user.company.cards.map{|c| c.update_attribute :active, false}
		@card = @user.company.cards.create :card_id => card_data.id, :last4 => card_data.last4, :exp_month => card_data.exp_month, :exp_year => card_data.exp_year, :brand => card_data.brand, :customer_token => customer.id
		redirect_to billing_admin_index_path
	end

	def update
		@card = Card.find params[:id]
		@card.update_attributes params[:card]
	end

	private

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
			@projects = @user.project_users.where(:archived => false).map(&:project).compact.uniq
			@company = @user.company
		end
	end

end
