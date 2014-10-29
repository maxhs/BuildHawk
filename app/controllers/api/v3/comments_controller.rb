class Api::V3::CommentsController < Api::V3::ApiController

    def show 
        if params[:checklist_item_id].present?
            checklist_item = ChecklistItem.find params[:report_id]
            comments = report.comments
        elsif params[:task_id].present?
            task = Task.find params[:task_id]
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
        params[:comment][:mobile] = true
        comment = Comment.create params[:comment]
        
        if params[:comment][:checklist_item_id].present?
            checklist_item = ChecklistItem.find params[:comment][:checklist_item_id]
            comments = checklist_item.comments
        elsif params[:comment][:task_id].present?
            task = Task.find params[:comment][:task_id]
            comments = task.comments
        elsif params[:comment][:report_id].present?
            report = Report.find params[:comment][:report_id]
            comments = report.comments
        end

        if comment.save
            respond_to do |format|
                format.json { render_for_api :projects, :json => comment, :root => :comment}
            end
        end
    end

    def destroy
        comment = Comment.find params[:id]
        #user = User.where(id: params[:user_id]).first
        if comment.destroy
            render :json => {success: true}
        else
            render :json => {success: false}
        end
    end

end
