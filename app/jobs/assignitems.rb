module AssignItems
	@queue = :assign_items
  	def self.perform(checklist_id)
  		puts "assigning checklist items in the background"
  		checklist = Checklist.find checklist_id
    	checklist.checklist_items << checklist.categories.map(&:subcategories).flatten.map(&:checklist_items).flatten
    	checklist.save!
  	end
end
