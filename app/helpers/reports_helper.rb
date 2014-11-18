module ReportsHelper
	include ActionView::Helpers::NumberHelper

	def wind_bearing(bearing)
		if (360 > bearing && bearing > 348.75) || (0 < bearing  && bearing < 11.25)
        	return "N"
  		elsif 33.75 > bearing && bearing > 11.25
        	return "NNE"
	    elsif 56.25 > bearing && bearing > 33.75
	        return "NE"
	    elsif 78.75 > bearing && bearing > 56.25
	        return "ENE"
	    elsif 101.25 > bearing && bearing > 78.75
	        return "E"
	    elsif 123.75 > bearing && bearing > 101.25
	        return "ESE"
	    elsif 146.25 > bearing && bearing > 123.75
	        return "SE"
	    elsif 168.75 > bearing && bearing > 146.25
	        return "SSE"
	    elsif 191.25 > bearing && bearing > 168.75
	        return "S"
	    elsif 213.75 > bearing && bearing > 191.25
	        return "SSW"
	    elsif 236.25 > bearing && bearing > 213.75
	        return "WSW"
	    elsif 258.75 > bearing && bearing > 236.25
	        return "W"
	    elsif 281.25 > bearing && bearing > 258.75
	        return "WNW"
	    elsif 303.75 > bearing && bearing > 281.25
	        return "NW"
	    elsif 326.25 > bearing && bearing > 303.75
	        return "NW"
	    elsif 348.75 > bearing && bearing > 326.25
	        return "NNW"
	    else 
	    	return ""
	    end
	end
end
