module ApplicationHelper
	def parse_time(time)
		time.strftime("%b %e, %l:%M %p")
	end
end
