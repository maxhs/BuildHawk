class Api::V2::NotificationsController < Api::V2::ApiController

    def index
        user = User.find params[:user_id]
        notifications = user.notifications
        respond_to do |format|
            format.json { render_for_api :notifications, :json => notifications, :root => :notifications}
        end
    end

end
