class Api::V1::ReportsController < Api::V1::ApiController

    def update
    	@report = Report.find params[:id]
    	@report.update_attributes params[:report]
    	respond_to do |format|
        	format.json { render_for_api :projects, :json => @report, :root => :report}
      	end
    end

    def show
    	project = Project.find params[:id]
    	reports = project.reports
    	respond_to do |format|
        	format.json { render_for_api :projects, :json => reports, :root => :reports}
      	end
    end

    def date
        @report = Report.where(:created_date => params[:created_date]).first
        respond_to do |format|
            format.json { render_for_api :projects, :json => @report, :root => :report}
        end
    end

    def prev
        current = Report.where(:created_date => params[:created_date]).first
        @report = Report.all.order('created_at DESC').find(current.id).offset(1)
        respond_to do |format|
            format.json { render_for_api :projects, :json => @report, :root => :report}
        end
    end

    def next
        current = Report.where(:created_date => params[:created_date]).first
        @report = Report.all.order('created_at DESC').find(current.id).offset(-1)
        respond_to do |format|
            format.json { render_for_api :projects, :json => @report, :root => :report}
        end
    end

    def create
        @report = Report.create params[:report]
        respond_to do |format|
            format.json { render_for_api :projects, :json => @report, :root => :report}
        end
    end

end
