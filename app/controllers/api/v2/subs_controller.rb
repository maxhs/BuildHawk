class Api::V2::SubsController < Api::V2::ApiController
	
	def create
		project = Project.find params[:project_id]
		company = project.company
		sub = company.subs.where(:name => params[:name]).first_or_create
		ProjectSub.where(:project_id => project.id, :name => params[:name]).first_or_create
		if sub.save
			respond_to do |format|
        		format.json { render_for_api :report, :json => sub, :root => :sub}
      		end
		else
			render json: { failure: false }
		end
	end

end
