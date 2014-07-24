class RegistrationsController < Devise::RegistrationsController
    def new
        super
    end

    def connect
        @user = User.new
        @user.first_name = "Max"
    end

    def alternates
        if request.xhr?
            respond_to do |format|
                format.js
            end
        else
            render :connect
        end
    end

    def find_company
        @user = User.new params[:user]
        if request.xhr?
            respond_to do |format|
                format.js
            end
        else
            render :connect
        end
    end

    def confirm
        @user = User.new params[:user]
        @user.company_id = params[:company_id] 
        if request.xhr?
            respond_to do |format|
                format.js
            end
        else
            render :connect
        end
    end

    def create
        if params[:user][:company]
            @company = Company.where(name: params[:user][:company][:name]).first_or_create!
            @company.projects.build unless @company.projects.count
        end

        super
        find_connect_items(current_user)
    end

    def update
        super
    end

    private

    def after_sign_up_path_for(resource)
        if @company && @company.users.count == 0
            admin_index_path
        else
            projects_path
        end
    end

    def find_connect_items(user)
        connect_user = ConnectUser.where(:email => user.email).first
        connect_user = ConnectUser.where(:phone => user.phone).first unless connect_user
        return unless connect_user
        tasks = connect_user.worklist_items
        tasks.each do |t|
            t.update_attributes :assignee_id => user.id, :connect_assignee_id => nil
            t.project.project_users.create :user_id => user.id
        end
    end
end 