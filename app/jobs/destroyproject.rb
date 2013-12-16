module DestroyProject
	@queue = :destroy_project
  	def self.perform(project_id)
  		puts "deleting project in the background"
  		project = Project.find project_id
    	project.destroy
  	end
end
