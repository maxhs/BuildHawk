class Api::V2::RemindersController < Api::V2::ApiController

	def create
		params[:reminder][:reminder_datetime] = Time.at(params[:date].to_i)
		reminder = Reminder.create params[:reminder]
		if reminder.save
			respond_to do |format|
        		format.json { render_for_api :projects, :json => reminder, :root => :reminder}
      		end
		else
			render json: {failure: false}
		end
	end

	def update
		reminder = Reminder.find params[:id]
		reminder.update_attributes params[:reminder]
		if reminder.save
			respond_to do |format|
        		format.json { render_for_api :projects, :json => reminder, :root => :reminder}
      		end
		else
			render json: {failure: false}
		end
	end

	def destroy
		reminder = Reminder.find params[:id]
		if reminder.destroy
			render json: {success: true}
		else
			render json: {failure: true}
		end
	end

end