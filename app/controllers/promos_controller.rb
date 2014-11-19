class PromosController < ApplicationController
	before_filter :authenticate_admin

	def create
		@promo = Promo.create params[:promo]
	end

	def edit
		@promo = Promo.find params[:id]
	end

	def update
		@promo = Promo.find params[:id]
		@promo.update_attributes params[:promo]
	end

	def destroy
		promo = Promo.find params[:id]
		@promo_id = promo.id
		promo.destroy
	end

end
