module AssignItems
	@queue = :assign_items
  	def self.perform(checklist)
  		puts "assigning checklist items in the background"
  		checklist.checklist_items << checklist.categories.order('name').map(&:subcategories).flatten.map(&:checklist_items).flatten
  		checklist.save
  	end
end
