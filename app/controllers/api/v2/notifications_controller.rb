class Api::V2::NotificationsController < Api::V2::ApiController

    def index
        user = User.find params[:user_id]
        notifications = user.notifications
        respond_to do |format|
            format.json { render_for_api :notifications, :json => notifications, :root => :notifications}
        end
    end

    def messages
        user = User.find params[:user_id]
        notifications = user.notifications.where(:notification_type => "Message")
        render json: {notifications: notifications}
    end

    def destroy
    	notification = Notification.find params[:id]
    	if notification.destroy
    		render json: {success: true}
    	else
    		render json: {failure: true}
    	end
    end

end
