module TasksHelper
	def cleanText(text)
		cleaned = text.partition('On Mon').first.html_safe
		cleaned = text.partition('On Tue').first.html_safe
		cleaned = text.partition('On Wed').first.html_safe
		cleaned = text.partition('On Thu').first.html_safe
		cleaned = text.partition('On Fri').first.html_safe
		cleaned = text.partition('On Sat').first.html_safe
		cleaned = text.partition('On Sun').first.html_safe
	end
end