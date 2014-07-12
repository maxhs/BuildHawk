class Api::V2::CompaniesController < Api::V2::ApiController

	def show
		company = Company.find params[:id]
    	render json: {company: {subcontractors: company.subcontractors.sort_by{|s|s.name.downcase}}}
	end	

	def search
		search_term = "%#{params[:search]}%" if params[:search]
		initial = Company.search do
			fulltext search_term
		end
		companies = initial.results.uniq
		render json: {companies: companies}
	end

end