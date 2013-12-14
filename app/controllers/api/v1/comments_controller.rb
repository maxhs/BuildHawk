class Api::V1::CommentsController < Api::V1::ApiController

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
        	format.json { render_for_api :checklist, :json => comments, :root => :checklist}
      	end
    end

    def create
        comment = Comment.create params[:comment]
        if params[:comment][:checklist_item_id].present?
            checklist_item = ChecklistItem.find params[:comment][:checklist_item_id]
            comments = report.comments
        elsif params[:comment][:punchlist_item_id].present?
            punchlist_item = PunchlistItem.find params[:comment][:punchlist_item_id]
            comments = report.comments
        elsif params[:comment][:report_id].present?
            report = Report.find params[:comment][:report_id]
            comments = report.comments
        end
        respond_to do |format|
            format.json { render_for_api :checklist, :json => comments, :root => :checklist}
        end
    end

    def destroy

    end

end
