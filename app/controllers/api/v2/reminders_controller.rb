class Api::V2::RemindersController < Api::V2::ApiController

	def create
		reminder = Reminder.create params[:reminder]
	end

	def update
		reminder = Reminder.update_attributes params[:reminder]
	end

end