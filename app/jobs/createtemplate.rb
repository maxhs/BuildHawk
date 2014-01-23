module CreateTemplate
	@queue = :create_template
  	def self.perform(company_id)
  		puts "creating a checklist template in the background"
      company = Company.find company_id
      checklist = Checklist.where(:core => true).last.dup :include => {:categories => {:subcategories => :checklist_items}}, :except => :core
      checklist.update_attributes :name => "New Checklist Template", :company_id => company.id, :core => false
      puts "done creating checklist from job"
  	end
end
