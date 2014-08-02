class Api::V3::ProjectSubsController < Api::V3::ApiController

	def create
		project = Project.find params[:project_id]
		name = "#{params[:subcontractor][:name]}"
		subcontractor = Company.where("name ILIKE ?",name).first_or_create
		subcontractor.update_attributes params[:subcontractor] 
		company.company_subs.create :subcontractor_id => subcontractor.id
    	respond_to do |format|
        	format.json { render_for_api :reports, :json => company, :root => :company}
      	end
	end

end