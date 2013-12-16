module AssignItems
	@queue = :assign_items
  	def self.perform(checklist_id)
  		puts "assigning checklist items in the background"
  		checklist = Checklist.find checklist_id
    	checklist.checklist_items << checklist.categories.order('name').map(&:subcategories).flatten.map(&:checklist_items).flatten
  	end
end
