class ChargesController < ApplicationController
	before_filter :authenticate_user!
	def new
		company = current_user.company
	  	active_projects = company.projects.where(:active => true).count
	  	@amount = active_projects * 1000 / 100
	  	puts "the amount is: #{@amount}"
	end

	def create
	  # Amount in cents
	  company = current_user.company
	  active_projects = company.projects.where(:active => true).flatten
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

end
