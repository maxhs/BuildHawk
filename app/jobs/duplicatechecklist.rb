module DuplicateChecklist
	@queue = :duplicate_checklist
  	def self.perform(checklist,company_id)
  		puts "duplicating a checklist template in the background"
  		if company_id
  			company = Company.find company_id
  			checklist.dup :include => [:company, {:categories => {:subcategories => :checklist_items}}], :except => {:categories => {:subcategories => {:checklist_items => :status}}}
  		else
      		checklist.dup :include => [{:categories => {:subcategories => :checklist_items}}], :except => {:categories => {:subcategories => {:checklist_items => :status}}}
      	end
      	puts "done creating checklist from job"
  	end
end
