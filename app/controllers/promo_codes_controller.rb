class PromoCodesController < ApplicationController
	before_filter :authenticate_user!

	def create
		company = current_user.company
		@promo_code = PromoCode.create params[:promo_code]		
		@promo_codes = PromoCode.all
	end

	def edit
		@promo_code = PromoCode.find params[:id]
		if request.xhr?
			respond_to do |format|
				format.js
			end
		else
			redirect_to promo_codes_uber_admin_index_path
		end
	end

	def cancel_editing
		@promo_code = PromoCode.find params[:id]
	end

	def update
		@promo_code = PromoCode.find params[:id]
		@promo_code.update_attributes params[:promo_code]
	end

end
