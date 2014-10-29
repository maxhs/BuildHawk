class Api::V3::CategoriesController < Api::V3::ApiController

    def show
    	category = Category.find params[:id]
    	respond_to do |format|
        	format.json { render_for_api :v3_checklists, :json => category, :root => :category}
      	end
    end

end