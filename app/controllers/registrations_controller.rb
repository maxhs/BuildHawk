class RegistrationsController < Devise::RegistrationsController
    layout "application", only:[:connect]
    def new
        super
    end

    def connect
        if current_user
            flash[:notice] = "You're already signed in.".html_safe
            redirect_to projects_path
            return
        end
        @user = User.find params[:user_id]
        
        #companies search
        if @user.company && @user.company.name.length > 0
            search_term = @user.company.name     
            initial = Company.search do
                fulltext search_term
            end
            @companies = initial.results.uniq
        end
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

    def confirm
        @user = User.create params[:user]
        sign_in @user
    end

    def create
        unless params[:beta_code] && params[:beta_code] == "BuildHawkBeta"
            flash[:notice] = "Sorry, but your beta code was invalid."
            return redirect_to register_url
        end

        unless params[:user] && params[:user][:password] && params[:user][:password_confirmation]
            if request.xhr?
                respond_to do |format|
                    format.js {render template:"connect/validate"}
                end
            else
                flash[:notice] = "Sorry, but something went wrong while trying to validate your account."
                return redirect_to root_url
            end
        end        

        if params[:user][:company][:name]
            @company = Company.where(name: params[:user][:company][:name]).first_or_create
            params[:user][:company_id] = @company.id
            unless @company.has_admin?
                params[:user][:company_admin] = true
                params[:user][:admin] = true
            end 
            params[:user].delete(:company)
        end
        
        super 
        
    end

    def update
        super
    end

    private

    def after_sign_up_path_for(resource)
        @company = current_user.company
        if current_user.any_admin?    
            admin_index_path
        else
            projects_path
        end
    end

end 