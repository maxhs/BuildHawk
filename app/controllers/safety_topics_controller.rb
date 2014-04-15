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
		@safety_topic = SafetyTopic.create params[:safety_topic]
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
		@uber_admin = true
		@safety_topics = SafetyTopic.where("company_id IS NULL")
		@safety_topic = SafetyTopic.find params[:id]
		if request.xhr?
			respond_to do |format|
				format.js
			end
		else
			render :index, layout: "uber_admin"
		end
	end

	def update
		@safety_topics = SafetyTopic.where("company_id IS NULL")
		@safety_topic = SafetyTopic.find params[:id]
		@safety_topic.update_attributes params[:safety_topic]
		if request.xhr?
			respond_to do |format|
				format.js
			end
		else
			render :index, layout: "uber_admin"
		end
	end

	def destroy
		@safety_topics = SafetyTopic.where("company_id IS NULL")
		@safety_topic = SafetyTopic.find params[:id]
		@safety_topic.destroy
		if request.xhr?
			respond_to do |format|
				format.js
			end
		else
			render :index, layout: "uber_admin"
		end
	end
end
