class SubsController < AppController
	before_filter :authenticate_user!
	
	def update
		sub = Sub.find params[:id]
		sub.update_attributes params[:sub]
	end
end
