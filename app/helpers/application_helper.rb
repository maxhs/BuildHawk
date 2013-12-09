module ApplicationHelper
	def parse_time(time)
		time.strftime("%b %e, %l:%M %p")
	end
	def parse_date(time)
		time.strftime("%m/%d/%Y")
	end
end
