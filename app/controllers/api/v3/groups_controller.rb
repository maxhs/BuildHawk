class Api::V3::GroupsController < Api::V3::ApiController

    def index
        @user = User.find params[:user_id]
        groups = @user.company.project_groups
        # group_ids = @user.company.project_users.where("project_group_id IS NOT NULL and archived = ? and core = ?",false,false).map(&:project_group_id).uniq
        # groups = []
        # if group_ids.count > 0
        #     group_ids.each do |g|
        #         groups << ProjectGroup.find(g)
        #     end 
        # end

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
