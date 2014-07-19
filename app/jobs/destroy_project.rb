class DestroyProject
  @queue = :destroy_project
  
  def self.perform(project_id)
    project = Project.where(:id => project_id).first
    project.destroy if project
  end  
end