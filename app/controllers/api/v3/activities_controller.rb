class Api::V3::ActivitiesController < Api::V3::ApiController

    def destroy
        activity = Activity.find params[:id]
        if activity.destroy
            render :json => {success: true}
        else
            render :json => {success: false}
        end
    end

end
