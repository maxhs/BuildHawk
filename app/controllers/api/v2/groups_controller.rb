class Api::V2::GroupsController < Api::V2::ApiController

    def index
        @user = User.find params[:user_id]
        group_ids = @user.project_users.where("project_group_id IS NOT NULL").map(&:project_group_id).uniq
        groups = []
        if group_ids.count > 0
            group_ids.each do |g|
                groups << ProjectGroup.find(g)
            end 
        end

        if groups.count > 0
            respond_to do |format|
                format.json { render_for_api :dashboard, :json => groups, :root => :groups}
            end
        else
            render :json => {success: false}
        end
    end

    def show
    	group = ProjectGroup.find params[:id]
    	respond_to do |format|
        	format.json { render_for_api :details, :json => group, :root => :project_groups}
      	end
    end

    def destroy
    	@photo = Photo.find params[:id]
    	if @photo.destroy
        	render :json=>{:success=>true}
      	else 
        	render :json=>{:success=>false}
      	end
    end

end
