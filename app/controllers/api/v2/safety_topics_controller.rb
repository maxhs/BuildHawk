class Api::V2::SafetyTopicsController < Api::V2::ApiController
	
	def destroy
		topic = SafetyTopic.find params[:id]
		report = topic.report if topic.report
		if topic.destroy
			render json: { success: true }
		else
			render json: { failure: false }
		end
	end

end
