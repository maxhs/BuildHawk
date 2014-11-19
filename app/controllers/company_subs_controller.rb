class CompanySubsController < AppController
	before_filter :authenticate_admin

	def new
		@subcontractor = CompanySub.new
		@subcontractor.build_subcontractor
	end

	def create
		company = Company.where(name: params[:company_sub][:subcontractor][:name]).first_or_create
		company_sub = current_user.company.company_subs.where(subcontractor_id: company.id).first_or_create
		company_sub.update_attributes contact_name: params[:company_sub][:contact_name],email: params[:company_sub][:email],phone: params[:company_sub][:phone]
		@users = current_user.company.users
		@subcontractors = current_user.company.company_subs
		
		if company_sub.save
			if request.xhr?
				respond_to do |format|
					format.js {render template:"admin/personnel"}
				end
			else
				redirect_to personnel_admin_index_path, alert: "Subcontractor created"
			end
		else
			redirect_to personnel_admin_index_path, alert: "Unable to create subcontractor. Please make sure the form is complete."
		end
	end

	def edit
		@company_sub = current_user.company.company_subs.where(:id => params[:id]).first
	end

	def update
		@company_sub = current_user.company.company_subs.where(:id => params[:id]).first
		@company_sub.update_attributes params[:company_sub][:subcontractor]
		redirect_to users_admin_index_path
	end
	
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
