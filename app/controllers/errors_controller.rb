class ErrorsController < ApplicationController
	def error_404
    	@not_found_path = params[:not_found]
  	end

  	def error_500
  
  	end

  	def not_found

	end

	def destroy
		error = Error.find params[:id]
		@error_id = error.id
		error.destroy
	end
end