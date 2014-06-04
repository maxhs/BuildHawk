class Api::V2::SafetyTopicsController < Api::V2::ApiController
	
	def destroy
		topic = ReportTopic.find params[:id]
		if topic.destroy
			render json: { success: true }
		else
			render json: { failure: false }
		end
	end

end
