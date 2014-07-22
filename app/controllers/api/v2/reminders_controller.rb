class Api::V2::RemindersController < Api::V2::ApiController

	def create
		
		if params[:reminder][:checklist_item_id]]
			reminder = Reminder.where(:user_id => params[:reminder][:user_id],:checklist_item_id => params[:reminder][:checklist_item_id]).first_or_create
			reminder.update_attribute :reminder_datetime, Time.at(params[:date].to_i)
			if reminder.save
				respond_to do |format|
	        		format.json { render_for_api :projects, :json => reminder, :root => :reminder}
	      		end
			else
				render json: {failure: false}
			end
		else
			render json: {success: false}
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