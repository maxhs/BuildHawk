class Api::V3::SafetyTopicsController < Api::V3::ApiController
	
	def destroy
		topic = ReportTopic.find params[:id]
		report = Report.find params[:report_id]
		if topic && report

			if report.report_topics.include? topic && topic.destroy
				render json: { success: true }
			else
				render json: { success: false }
			end
		else 
			render json: { success: false }
		end
	end

end
