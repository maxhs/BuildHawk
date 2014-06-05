class Api::V2::CompanySubsController < Api::V2::ApiController

	def create
		company = Company.find params[:company_id]
		subcontractor = Company.where("name ILIKE #{params[:subcontractor][:name]}").first_or_create
		company.company_subs.create :subcontractor => subcontractor
    	respond_to do |format|
        	format.json { render_for_api :report, :json => company, :root => :company}
      	end
	end

end