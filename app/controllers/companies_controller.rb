class CompaniesController < AppController
	before_filter :authenticate_user!, :except => [:create, :search]

	def index
		
	end

	def create
		@company = Company.create params[:company]
	end

	def search
		@user = User.new params[:user]
		puts "found a user: #{@user.first_name}"
		if params[:search] && params[:search].length > 0
			search_term = "#{params[:search]}" 
			puts "Search term: #{search_term}"
			initial = Company.search do
				fulltext search_term
			end
			@companies = initial.results.uniq
			@prompt = "No search results"
		else 
			@companies = nil
		end
		puts "Company search count: #{@companies.count}" if @companies
		if request.xhr?
			respond_to do |format|
				format.js
			end
		end
	end
end
