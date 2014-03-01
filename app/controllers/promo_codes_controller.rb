class PromoCodesController < ApplicationController
	before_filter :authenticate_user!
	before_filter :find_code

	def create
		company = current_user.company
		@promo_code = PromoCode.create params[:promo_code]		
		@promo_codes = PromoCode.all
	end

	def edit
		@companies = Company.all
		if request.xhr?
			respond_to do |format|
				format.js
			end
		else
			redirect_to promo_codes_uber_admin_index_path
		end
	end

	def cancel_editing
		
	end

	def update
		@promo_code.update_attributes params[:promo_code]
	end

	def destroy
		@id = @promo_code.id
		@promo_code.destroy
		if request.xhr?
			respond_to do |format|
				format.js
			end
		else
			redirect_to promo_codes_uber_admin_index_path
		end
	end

	private

	def find_code
		@promo_code = PromoCode.find params[:id] if params[:id]
	end
end
