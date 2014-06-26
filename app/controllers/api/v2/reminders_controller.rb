class Api::V2::RemindersController < Api::V2::ApiController

	def create
		params[:reminder][:reminder_datetime] = Time.at(params[:date]).to_datetime
		reminder = Reminder.create params[:reminder]
		if reminder.save
			render json: {success: true}
		else
			render json: {failure: false}
		end
	end

	def update
		reminder = Reminder.update_attributes params[:reminder]
	end

end