class CardsController < ApplicationController
	before_filter :find_user

	def new
		@card = @company.cards.new
	end

	def create

	end

	def update
		@card = Card.find params[:id]
		redirect_to billing_admin_index_path, notice: "Sorry, but you don't have access to that page.".html_safe unless current_user.company.cards.include?(@card)

		if params[:primary].present? && params[:primary] == "true"
			current_user.cards.each do |c|
				unless c == @card
					c.update_attribute :primary, false
				else
					c.update_attribute :primary, true
				end
			end
		end
	end

	def destroy
		card = Card.find params[:id]
		customer = Stripe::Customer.retrieve(@company.customer_id)
		stripe_card = customer.cards.retrieve(card.card_id)
		stripe_card.delete if stripe_card 
		card.destroy
		redirect_to billing_index_path
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
			@projects = @user.project_users.where(:hidden => false).map(&:project).compact.uniq
			@company = @user.company
		end
	end
end
