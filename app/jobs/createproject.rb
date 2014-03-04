module CreateProject
	@queue = :create_project
  	def self.perform(params, template_id)
  		puts "create project in the background"
  		if template_id && Checklist.find(template_id) 
  			list = Checklist.find template_id
  			@checklist = list.dup :include => [:company, {:categories => {:subcategories => :checklist_items}}]#, :except => {:categories => {:subcategories => {:checklist_items => :status}}}
  			@checklist.save
  		else 
  			@checklist = Checklist.where(:core => true).last.dup :include => {:categories => {:subcategories => :checklist_items}}#, :except => {:categories => {:subcategories => {:checklist_items => :status}}}
  			@checklist.save
  		end
  		@project = Project.create params
  		@project.checklist = @checklist
  		puts "done creating project with checklist: #{@checklist.id}"
  	end
end
