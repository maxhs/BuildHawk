class Api::V2::MessagesController < Api::V2::ApiController

    def index
        user = User.find params[:user_id]
        messages = user.messages
        respond_to do |format|
            format.json { render_for_api :messages, :json => messages, :root => :messages}
        end
    end

    def destroy
    	message = Message.find params[:id]
    	if notification.destroy
    		render json: {success: true}
    	else
    		render json: {failure: true}
    	end
    end

end
