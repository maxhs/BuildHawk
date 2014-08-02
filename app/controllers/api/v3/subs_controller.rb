class Api::V3::SubsController < Api::V3::ApiController
	
	def create
		project = Project.find params[:project_id]
		company = project.company
		sub = company.subs.where(:name => params[:name]).first_or_create
		ps = ProjectSub.where(:project_id => project.id, :sub_id => sub.id).first_or_create
		if ps.save
			respond_to do |format|
        		format.json { render_for_api :reports, :json => sub, :root => :sub}
      		end
		else
			render json: { failure: false }
		end
	end

end
