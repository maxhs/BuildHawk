class Api::V2::CompanySubsController < Api::V2::ApiController

	def create
		company = Company.find params[:company_id]
		name = "#{params[:subcontractor][:name]}"
		subcontractor = Company.where("name ILIKE ?",name).first_or_create
		subcontractor.update_attributes params[:subcontractor] 
		company.company_subs.create :subcontractor_id => subcontractor.id
    	respond_to do |format|
        	format.json { render_for_api :report, :json => company, :root => :company}
      	end
	end

	def add_user
		company = CompanySub.find params[:id]
		if params[:user][:email]
			user = User.where(:email => params[:user][:email]).first
			unless user
				alternate = Alternate.where(:email => params[:user][:email]).first
				user = alternate.user if alternate
			end
		
			user = company.subcontractor.users.create params[:user] unless user
		
			respond_to do |format|
	        	format.json { render_for_api :user, :json => user, :root => :user}
	      	end
		elsif params[:user][:phone]
			user = User.where(:phone => params[:user][:phone]).first
			unless user
				alternate = Alternate.where(:phone => params[:user][:phone]).first
				user = alternate.user if alternate
			end
		
			user = company.subcontractor.users.create params[:user] unless user
			
			respond_to do |format|
		       	format.json { render_for_api :user, :json => user, :root => :user}
	      	end
		end
	end

end