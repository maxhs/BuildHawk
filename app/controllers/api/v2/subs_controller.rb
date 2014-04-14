class Api::V2::SubsController < Api::V2::ApiController
	
	def create
		@project = Project.find params[:project_id]
		sub = Sub.create params
		sub.update_attributes params[:sub]
	end

end
