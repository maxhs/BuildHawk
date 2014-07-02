class Api::V2::ActivitiesController < Api::V2::ApiController

    def destroy
        activity = Activity.find params[:id]
        if activity.destroy
            render :json => {success: true}
        else
            render :json => {success: false}
        end
    end

end
