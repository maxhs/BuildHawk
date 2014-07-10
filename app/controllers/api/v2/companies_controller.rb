class Api::V2::CompaniesController < Api::V2::ApiController

	def show
		company = Company.find params[:id]
    	render json: {company: {subcontractors: company.subcontractors}}
    	#respond_to do |format|
        #	format.json { render_for_api :projects, :json => company, :root => :company}
      	#end
	end	

end