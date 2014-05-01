class SolrUpdate
  @queue = :solr
  
  def self.perform(classname, id)
  	puts "performing solr update for: #{classname id}"
    classname.constantize.find(id).solr_index
  end  
end