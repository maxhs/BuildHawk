module ApplicationHelper
	def parse_time(time)
		time.strftime("%b %e, %l:%M %p") if time
	end
	def parse_date(time)
		time.strftime("%m/%d/%Y") if time
	end
	def parse_datetime(time)
		time.strftime("%b %e, %l:%M %p")
	end
	def parse_billing_date(time)
		time.strftime("%B %Y") if time
	end
	def parse_month_date(time)
		time.strftime("%B %e") if time
	end
	def parse_month_date_year(time)
		time.strftime("%B %e, %Y") if time
	end
end
