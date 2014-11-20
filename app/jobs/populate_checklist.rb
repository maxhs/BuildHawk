class PopulateChecklist
  	@queue = :populate_checklist
  
  	def self.perform(new_checklist_id, template_id)
    	checklist = Checklist.where(id: new_checklist_id).first
    	template = Checklist.where(id: template_id).first
    	checklist = template.dup :include => {:phases => {:categories => :checklist_items}}, :except => {:phases => {:categories => {:checklist_items => :state}}}
  		checklist.save!
  	end  
end
