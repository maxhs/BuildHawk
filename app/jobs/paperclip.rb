module Paperclip
	@queue = :paperclip
  	def self.perform
  		puts "paperclip in the background"
  	end
end
