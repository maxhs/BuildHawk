class Api::V2::CompaniesController < Api::V2::ApiController

	def show
		company = Company.find params[:id]
    	render json: {company: {subcontractors: company.subcontractors.sort_by{|s|s.name.downcase}}}
	end	

end