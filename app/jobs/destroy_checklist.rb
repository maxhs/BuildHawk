class DestroyChecklist
  	@queue = :destroy_checklist
  
  	def self.perform(checklist_id)
    	checklist = Checklist.where(id: checklist_id).first
    	checklist.destroy if checklist
  	end  
end