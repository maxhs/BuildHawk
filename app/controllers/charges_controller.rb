class ChargesController < ApplicationController
	before_filter :authenticate_user!
	def index
		company = current_user.company
		@charges = company.charges
	  	active_projects = company.projects.where(:active => true).count
	  	@amount = active_projects * 1000 / 100
	  	puts "the amount is: #{@amount}"
	end

	def new
		redirect_to charges_path
	end

	def create
	  # Amount in cents
	  company = current_user.company
	  active_projects = company.projects.where(:active => true).count
	  @amount = active_projects * 1000
	  puts "the amount is: #{@amount}"
	  customer = Stripe::Customer.create(
	    :email => current_user.email,
	    :card  => params[:stripeToken]
	  )

	  charge = Stripe::Charge.create(
	    :customer    => customer.id,
	    :amount      => @amount,
	    :description => company.name,
	    :currency    => 'usd'
	  )

	rescue Stripe::CardError => e
	  flash[:error] = e.message
	  redirect_to charges_path
	end

	def promo_code
		charge = Charge.find params[:id]
		charge.update_attribute :promo_code, params[:charge][:promo_code]
		if request.xhr?
			respond_to do |format|
				format.js
			end
		else
			redirect_to charges_path
		end
	end

end
