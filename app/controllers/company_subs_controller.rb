class CompanySubsController < ApplicationController

	def destroy
		subcontractor = CompanySub.find params[:id]
		@subcontractor_id = subcontractor.id
		subcontractor.destroy
		flash[:notice] = "Subcontractor removed"
		if request.xhr?
			respond_to do |format|
				format.js
			end
		else
			redirect_to users_admin_index_path
		end
	end

end
