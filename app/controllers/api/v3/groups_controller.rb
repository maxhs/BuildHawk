class Api::V3::GroupsController < Api::V3::ApiController

    def index
        @user = User.find params[:user_id]
        groups = @user.company.project_groups

        if groups.count > 0
            respond_to do |format|
                format.json { render_for_api :details, :json => groups, :root => :groups}
            end
        else
            render json: {success: false}
        end
    end

    def show
    	group = ProjectGroup.find params[:id]
    	respond_to do |format|
        	format.json { render_for_api :details, :json => group, :root => :group}
      	end
    end

    def destroy
    	@photo = Photo.find params[:id]
    	if @photo.destroy
        	render json: {success: true}
      	else 
        	render json: {success: false}
      	end
    end

end
