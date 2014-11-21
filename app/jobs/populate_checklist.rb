class PopulateChecklist
  	@queue = :populate_checklist
  
  	def self.perform(company_id, project_id, template_id)
    	template = Checklist.where(id: template_id).first
    	checklist = template.deep_clone :include => {:phases => {:categories => :checklist_items}}, :except => {:phases => {:categories => {:checklist_items => :state}}}
  		if project_id
  			checklist.core = false
  			checklist.project_id = project_id
  		else
  			checklist.core = true
  		end
  		checklist.company_id = company_id
  		checklist.save!
  	end  
end
