class SafetyTopicsController < ApplicationController

	def new
		@safety_topic = SafetyTopic.new
		if request.xhr?
			respond_to do |format|
				format.js
			end
		else
			redirect_to safety_topics_path
		end
	end

	def create
		@st = SafetyTopic.create params[:safety_topic]
	end

	def index
		@uber_admin = true
		@safety_topics = SafetyTopic.where("company_id IS NULL")
		if request.xhr?
			respond_to do |format|
				format.js
			end
		else
			render :index
		end
	end

	def edit
		@st = SafetyTopic.find params[:id]
	end

	def update

	end
end
