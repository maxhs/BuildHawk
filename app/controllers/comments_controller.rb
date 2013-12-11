class CommentsController < ApplicationController

	def create
		puts "should be creating a new comment"
		@comment = Comment.create params[:comment]
		@report = Report.find params[:comment][:report_id]
		@comments = @report.comments
	end
end
