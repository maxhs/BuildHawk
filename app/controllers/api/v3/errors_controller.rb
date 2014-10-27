class Api::V3::ErrorsController < Api::V3::ApiController

    def create
		puts "Error: #{params[:error]}"
		Error.create params[:error]
    	render json: {success: true}
    end

end