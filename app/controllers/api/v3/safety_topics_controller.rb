class Api::V3::SafetyTopicsController < Api::V3::ApiController
	
	def destroy
		topic = ReportTopic.find params[:id]

		## this is a check to make sure the user isn't deleting a report topic they shouldn't be deleting
		report = Report.find params[:report_id]
		report = topic.report unless report
		##

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
