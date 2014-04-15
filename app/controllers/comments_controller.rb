class CommentsController < ApplicationController
	before_filter :authenticate_user!
	def create
		@comment = Comment.create params[:comment]
		if params[:comment][:report_id].present?
			@report = Report.find params[:comment][:report_id]
			@comments = @report.comments
		elsif params[:comment][:checklist_item_id].present?
			@checklist_item = ChecklistItem.find params[:comment][:checklist_item_id]
			@comments = @checklist_item.comments
		elsif params[:comment][:punchlist_item_id].present?
			@punchlist_item = PunchlistItem.find params[:comment][:punchlist_item_id]
			@comments = @punchlist_item.comments
		end
	end

	def destroy
		puts "should be destroying a comment with id: #{params[:id]}"
		@comment = Comment.find params[:id]
		if @comment.report_id != nil
			@report = @comment.report
			@comment.destroy
			@comments = @report.comments
		elsif @comment.checklist_item_id != nil
			@checklist_item = @comment.checklist_item
			@comment.destroy
			@comments = @checklist_item.comments
		elsif @comment.punchlist_item_id != nil
			@punchlist_item = @comment.punchlist_item
			@comment.destroy
			@comments = @punchlist_item.comments
		end

		if request.xhr?
			respond_to do |format|
				format.js
			end
		else
			if @punchlist_item
				render "projects/edit_worklist_item"
			elsif @checklist_item
				render "projects/checklist_item"
			elsif @report
				render "projects/edit_report"
			end
		end
	end
end
