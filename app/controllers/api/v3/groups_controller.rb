class Api::V3::GroupsController < Api::V3::ApiController

    def index
        user = User.find params[:user_id]
        groups = user.company.project_groups

        if groups.count > 0
            render json: {groups: groups.map{|group| {id: group.id, name: group.name, projects_count: group.projects_count, projects: group.projects.map{|project| {id: project.id, name: project.name, address: project.address, users: project.users.map{|user| {id:user.id}}, hidden: project.hidden_for_user?(user) } } } } }
            #respond_to do |format|
            #    format.json { render_for_api :details, :json => groups, :root => :groups}
            #end
        else
            render json: {success: false}
        end
    end

    def show
    	group = ProjectGroup.find params[:id]
        user = User.find params[:user_id]
    	render json: {id: group.id, name: group.name, projects: group.projects.map{|project| {name: project.name, hidden: project.hidden_for_user?(user), address: project.address} } }
        #respond_to do |format|
        #	format.json { render_for_api :details, :json => group, :root => :group}
      	#end
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
