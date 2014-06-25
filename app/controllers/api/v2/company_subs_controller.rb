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
		company = Company.find params[:company_id]
		puts "found company: #{company.name}"
		company_sub = company.company_subs.where(:id => params[:id]).first_or_create
		puts "found company_sub: #{company_sub.name}"
		task = WorklistItem.find params[:task_id] if params[:task_id]
		if params[:user][:email]
			user = User.where(:email => params[:user][:email]).first
			if user
				#existing user
			else
				alternate = Alternate.where(:email => params[:user][:email]).first
				user = alternate.user if alternate
			end
		
			unless user
				puts "could find user for task assignment: #{params[:user]}"
				task.update_attribute :assigned_email, params[:user][:email]
				task.update_attributes :assigned_name => "#{params[:user][:first_name]} #{params[:user][:last_name]}"
			end
		
			respond_to do |format|
	        	format.json { render_for_api :user, :json => user, :root => :user}
	      	end
		elsif params[:user][:phone]
			user = User.where(:phone => params[:user][:phone]).first
			if user
				#existing user
				user.text_task(task) if task
			else
				alternate = Alternate.where(:phone => params[:user][:phone]).first
				if alternate
					user = alternate.user
					user.text_task(task) if task
				end
			end
		
			unless user
				puts "could find user for task assignment: #{params[:user]}"
				task.update_attribute :assigned_phone, params[:user][:phone]
				task.update_attributes :assigned_name => "#{params[:user][:first_name]} #{params[:user][:last_name]}"
			end

			respond_to do |format|
		       	format.json { render_for_api :user, :json => user, :root => :user}
	      	end
		end
	end

end