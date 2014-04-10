class PunchlistItemsController < ApplicationController
	before_filter :authenticate_user!
	before_filter :find_company

	def new
		@item = PunchlistItem.new
		@item.photos.build
		@item.build_assignee
		@project = Project.find params[:project_id]
		@company = @project.company
		@projects = @company.projects
		@users = @project.users
		@subs = @project.subs
	
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
		if @project.punchlists.count == 0
			@punchlist = @project.punchlists.create
		else
			@punchlist = @project.punchlists.first
		end
		if params[:punchlist_item][:assignee_attributes].present?
			assignee = User.where(:full_name => params[:punchlist_item][:assignee_attributes][:full_name]).first
			sub_assignee = Sub.where(:name => params[:punchlist_item][:assignee_attributes][:full_name]).first unless assignee
			params[:punchlist_item].delete(:assignee_attributes)
		end

		@item = @punchlist.punchlist_items.create params[:punchlist_item]
		
		if assignee
			@item.update_attribute :assignee_id, assignee.id
		elsif sub_assignee
			@item.update_attribute :sub_assignee_id, sub_assignee.id
		end

		@items = @punchlist.punchlist_items if @punchlist
		if request.xhr?
			respond_to do |format|
				format.js { render :template => "projects/worklist"}
			end
		else 
			redirect_to worklist_project_path(@project)
		end
	end

	def edit
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
		if params[:punchlist_item][:assignee_attributes].present?
			assignee = User.where(:full_name => params[:punchlist_item][:assignee_attributes][:full_name]).first
			params[:punchlist_item].delete(:assignee_attributes)
			if assignee
				params[:punchlist_item][:assignee_id] = assignee.id 
			else
				params[:punchlist_item][:assignee_id] = nil 
			end
		end
				
		if params[:punchlist_item][:completed] == "true"
			params[:punchlist_item][:completed_by_user_id] = current_user.id
			params[:punchlist_item][:completed_at] = Time.now
		else

			params[:punchlist_item][:completed_by_user_id] = nil
			params[:punchlist_item][:completed_at] = nil
		end
		puts "params punchlist item: #{params[:punchlist_item]}"
		@item.update_attributes params[:punchlist_item]

		if request.xhr?
			respond_to do |format|
				format.js { render :template => "projects/worklist"}
			end
		else 
			redirect_to worklist_project_path(@project)
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
			PunchlistItemMailer.punchlist_item(@item,@recipient).deliver
		elsif @item.sub_assignee
			@recipient = @item.sub_assignee
			PunchlistItemMailer.punchlist_item(@item,@recipient).deliver
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
			@item = PunchlistItem.find params[:id] 
			@punchlist = @item.punchlist
			@project = @punchlist.project
			@items = @punchlist.punchlist_items
			@company = @project.company
			@projects = @company.projects
			@users = @project.users
			@subs = @project.subs
		end
	end
end
