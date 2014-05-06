class Api::V2::CommentsController < Api::V2::ApiController

    def index
    	@user = User.find params[:user_id]
    	projects = @user.projects
    	respond_to do |format|
        	format.json { render_for_api :projects, :json => projects, :root => :projects}
      	end
    end

    def show
        if params[:checklist_item_id].present?
            checklist_item = ChecklistItem.find params[:report_id]
            comments = report.comments
        elsif params[:punchlist_item_id].present?
            punchlist_item = PunchlistItem.find params[:punchlist_item_id]
            comments = report.comments
        elsif params[:report_id].present?
            report = Report.find params[:report_id]
            comments = report.comments
        end
    	respond_to do |format|
        	format.json { render_for_api :projects, :json => comments, :root => :comments}
      	end
    end

    def create
        comment = Comment.create params[:comment]
        comment.update_attribute :mobile, true
        if params[:comment][:checklist_item_id].present?
            checklist_item = ChecklistItem.find params[:comment][:checklist_item_id]
            comments = checklist_item.comments
        elsif params[:comment][:punchlist_item_id].present?
            punchlist_item = PunchlistItem.find params[:comment][:punchlist_item_id]
            comments = punchlist_item.comments
        elsif params[:comment][:report_id].present?
            report = Report.find params[:comment][:report_id]
            comments = report.comments
        end
        if comment.save
            respond_to do |format|
                format.json { render_for_api :projects, :json => comments, :root => :comments}
            end
        end
    end

    def destroy
        comment = Comment.find params[:id]
        if comment.destroy
            render :json => {success: true}
        else
            render :json => {success: false}
        end
    end

end
