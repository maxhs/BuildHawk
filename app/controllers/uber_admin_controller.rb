class UberAdminController < ApplicationController

	def index
		@checklist = Checklist.new
		core_checklist = CoreChecklist.last
		if core_checklist
			@items = core_checklist.categories.map(&:subcategories).flatten.map(&:checklist_items).flatten
		end
	end

	def upload_template
		puts "anything?"
		Checklist.import(params[:checklist][:file])
		redirect_to uber_admin_index_path
	end

	def import_checklist
		Checklist.import(params[:file])
	end

	def edit_item
		@checklist_item = ChecklistItem.find params[:id]

	end

	def update_item

	end

end
