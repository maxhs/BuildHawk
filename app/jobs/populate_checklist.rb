class PopulateChecklist
  	@queue = :populate_checklist
  
  	def self.perform(company_id, template_id)
    	template = Checklist.where(id: template_id).first
    	checklist = template.deep_clone :include => {:phases => {:categories => :checklist_items}}, :except => {:phases => {:categories => {:checklist_items => :state}}}
  		checklist.core = true
  		checklist.company_id = company_id
  		checklist.save!
  	end  
end
