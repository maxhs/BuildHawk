class Api::V3::NotificationsController < Api::V3::ApiController

    def index
        user = User.find params[:user_id]
        notifications = user.notifications
        respond_to do |format|
            format.json { render_for_api :notifications, json: notifications, root: :notifications}
        end
    end

    def messages
        user = User.find params[:user_id]
        notifications = user.notifications.where("notification_type = ? and message_id IS NOT NULL", "Message")
        respond_to do |format|
            format.json { render_for_api :notifications, json: notifications, root: :notifications}
        end
    end

    def destroy
    	notification = Notification.find params[:id]
    	if notification.destroy
    		render json: {success: true}
    	else
    		render json: {failure: true}
    	end
    end

    def test_android_pushes
        if params[:notification][:message]
            params[:notification][:body] = params[:notification][:message]
            params[:notification].delete(:message)
        end
        notification = Notification.create params[:notification]
        if notification.save
            render json: {notification: notification}
        else
            render json: {failure: true}
        end
    end

end
