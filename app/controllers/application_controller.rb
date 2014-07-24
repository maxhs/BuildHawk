class ApplicationController < ActionController::Base
    # Prevent CSRF attacks by raising an exception.
    # For APIs, you may want to use :null_session instead.
    protect_from_forgery with: :exception
    #after_filter :store_location
    before_filter :detect_redirect
    before_filter :configure_permitted_parameters, if: :devise_controller?

    def detect_redirect
        @mobile_redirect = true if params[:mobile]
    end

	def store_location
        # store last url - this is needed for post-login redirect to whatever the user last visited.
        if (request.fullpath != "/sign_in" &&
            request.fullpath != "/login" && \
            request.fullpath != "/sign_up" && \
            request.fullpath != "/register" && \
            request.fullpath != "/password" && \
            request.format == "text/html" && \
            !request.xhr?) # don't store ajax calls
          session[:previous_url] = request.fullpath
        end
    end

    def after_sign_in_path_for(resource)
        projects_path
        #session[:previous_url] || root_path
    end

	unless Rails.application.config.consider_all_requests_local
    	rescue_from Exception, with: lambda { |exception| render_error 500, exception }
    	rescue_from ActionController::RoutingError, ActionController::UnknownController, ::AbstractController::ActionNotFound, ActiveRecord::RecordNotFound, with: lambda { |exception| render_error 404, exception }
  	end

  	private
  	
    def render_error(status, exception)
        puts "Error exception: #{exception}"
    	respond_to do |format|
      		format.html { render template: "errors/error_#{status}", layout: 'layouts/application', status: status }
      		format.all { render nothing: true, status: status }
    	end
  	end

    def configure_permitted_parameters
        devise_parameter_sanitizer.for(:sign_up) << [:first_name, :last_name, :company, :company_id, :phone]
    end

end