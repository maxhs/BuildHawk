class Api::V3::SafetyTopicsController < Api::V3::ApiController
	
	def destroy
		topic = ReportTopic.find params[:id]
		if topic.destroy
			render json: { success: true }
		else
			render json: { failure: false }
		end
	end

end
