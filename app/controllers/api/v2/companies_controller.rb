class Api::V2::CompaniesController < Api::V2::ApiController

	def show
		company = Company.find params[:id]
    	render json: {company: {subcontractors: company.subcontractors.sort_by{|s|s.name.downcase}}}
	end	

	def search
		if params[:search]
			companies = []
			params[:search].split(' ').each do |s|
				search_term = "%#{s}%" 
				initial = Company.search do
					fulltext search_term#, minimum_match: 1
				end
				companies += initial.results.uniq
			end
			render json: {companies: companies.uniq}
		else
			render json: {success: false}
		end
	end

	def add
		company = Company.where(:name => params[:name]).first_or_create
		project = Project.find params[:project_id]
		project.companies << company unless project.companies.flatten.include?(company)
		render json: {company: company}
	end

end