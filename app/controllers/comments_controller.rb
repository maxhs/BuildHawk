class CommentsController < AppController
	before_filter :authenticate_user!
	
	def create
		@comment = Comment.create params[:comment]
		if params[:comment][:report_id].present?
			@report = Report.find params[:comment][:report_id]
			@comments = @report.comments
		elsif params[:comment][:checklist_item_id].present?
			@checklist_item = ChecklistItem.find params[:comment][:checklist_item_id]
			@comments = @checklist_item.comments
		elsif params[:comment][:task_id].present?
			@task = Task.where(id: params[:comment][:task_id]).first
			@comments = @task.comments if @task
		end
		if request.xhr?
			respond_to do |format|
				format.js
			end
		else
			redirect_to project_path(@comment.project)
		end
	end

	def destroy
		comment = Comment.find params[:id]
		@comment_id = comment.id
		if comment.report_id != nil
			@report = comment.report
			comment.destroy
			@comments = @report.comments
		elsif comment.checklist_item_id != nil
			@checklist_item = comment.checklist_item
			comment.destroy
			@comments = @checklist_item.comments
		elsif comment.task_id != nil
			@task = comment.task
			comment.destroy
			@comments = @task.comments
		end

		if request.xhr?
			respond_to do |format|
				format.js
			end
		else
			redirect_to project_path(@comment.project)
		end
	end
end
