class AdminController < ApplicationController

	def index
		@core_checklist = CoreChecklist.last
	end

	def edit_item

	end
end