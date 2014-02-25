class PromoCodesController < ApplicationController
	before_filter :authenticate_user!

	def create
		@promo_code = PromoCode.create params[:promo_code]
		company = current_user.company
		@promo_codes = company.promo_codes
	end
end
