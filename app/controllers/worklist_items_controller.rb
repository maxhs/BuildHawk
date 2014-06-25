class WorklistItemsController < ApplicationController
	before_filter :find_company
	before_filter :authenticate_user!, except: [:edit]
	
	def new
		@item = WorklistItem.new
		@item.photos.build
		@item.build_assignee
		@project = Project.find params[:project_id]
		@company = @project.company
		@projects = @company.projects
		@users = @project.users
		@subs = @project.subs
		@locations = @project.worklists.last.worklist_items.map{|i| i.location if i.location && i.location.length > 0}.flatten
		if request.xhr?
			respond_to do |format|
				format.js
			end
		else 
			render :new
		end
	end

	def create
		@project = Project.find params[:project_id]
		if @project.worklists.count == 0
			@worklist = @project.worklists.create
		else
			@worklist = @project.worklists.first
		end
		if params[:worklist_item][:assignee_attributes].present?
			assignee = User.where(:full_name => params[:worklist_item][:assignee_attributes][:full_name]).first
			sub_assignee = Sub.where(:name => params[:worklist_item][:assignee_attributes][:full_name]).first unless assignee
			params[:worklist_item].delete(:assignee_attributes)
		end

		@item = @worklist.worklist_items.create params[:worklist_item]
		
		if assignee
			@item.update_attribute :assignee_id, assignee.id
		elsif sub_assignee
			@item.update_attribute :sub_assignee_id, sub_assignee.id
		end

		@items = @worklist.worklist_items if @worklist
		if request.xhr?
			respond_to do |format|
				format.js { render :template => "projects/worklist"}
			end
		else 
			redirect_to worklist_project_path(@project)
		end
	end

	def edit
		@locations = @worklist.worklist_items.map{|i| i.location if i.location && i.location.length > 0}.flatten
		@item.build_assignee if @item.assignee.nil?
		if request.xhr?
			respond_to do |format|
				format.js
			end
		else 
			render :edit
		end
	end

	def update
		unless user_signed_in?
			if request.xhr?
				respond_to do |format|
					format.js { render :template => "worklist_items/login"}
				end
			else 
				redirect_to login_path
			end
		else
			if params[:worklist_item][:assignee_attributes].present?
				assignee = User.where(:full_name => params[:worklist_item][:assignee_attributes][:full_name]).first
				params[:worklist_item].delete(:assignee_attributes)
				if assignee
					params[:worklist_item][:assignee_id] = assignee.id 
				else
					params[:worklist_item][:assignee_id] = nil 
				end
			end
					
			if params[:worklist_item][:completed] == "true"
				params[:worklist_item][:completed_by_user_id] = current_user.id
				params[:worklist_item][:completed_at] = Time.now
			else
				params[:worklist_item][:completed_by_user_id] = nil
				params[:worklist_item][:completed_at] = nil
			end
			@item.update_attributes params[:worklist_item]

			@item.activities.create(
				:user_id => current_user.id,
				:body => ,
				:activity_type => @item.class.name
			)
			if request.xhr?
				respond_to do |format|
					format.js { render :template => "projects/worklist"}
				end
			else 
				redirect_to worklist_project_path(@project)
			end
		end
	end
		
	def destroy
		@item.destroy!
		if request.xhr?
			respond_to do |format|
				format.js
			end
		else
			redirect_to worklist_project_path(@project)
		end
	end

	def generate
		if @item.assignee
			@recipient = @item.assignee
			WorklistItemMailer.worklist_item(@item,@recipient).deliver
		elsif @item.sub_assignee
			@recipient = @item.sub_assignee
			WorklistItemMailer.worklist_item(@item,@recipient).deliver
		end
		if request.xhr?
			respond_to do |format|
				format.js
			end
		else
			redirect_to worklist_project_path(@project)
		end
	end

	def find_company
		if params[:id]
			@item = WorklistItem.find params[:id] 
			@worklist = @item.worklist
			@project = @worklist.project
			@items = @worklist.worklist_items
			@company = @project.company
			@projects = @company.projects
			@users = @project.users
			@subs = @project.company_subs
		end
	end
end
