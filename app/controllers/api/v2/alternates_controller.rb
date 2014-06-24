class Api::V2::MessagesController < Api::V2::ApiController

    def create
        user = User.find params[:user_id]
    	if params[:email]
            alternate = user.alternates.create :email => params[:email]
        elsif params[:phone]
            alternate = user.alternates.create :phone => params[:phone]
        end

    	if alternate.save
    		respond_to do |format|
                format.json { render_for_api :user, :json => alternate, :root => :alternate}
            end
    	else
    		render json: {success: false}
    	end
    end

end
