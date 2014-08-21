class ErrorsController < AppController
	def error_404
    	@not_found_path = params[:not_found]
  	end

  	def error_500
  
  	end

  	def not_found

	end

	def show
		
	end
end
