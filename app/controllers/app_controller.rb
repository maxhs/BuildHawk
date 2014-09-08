class AppController < ApplicationController
	before_filter :user_projects
	layout 'app'

    def user_projects
        if user_signed_in?
            if current_user.any_admin?
                #@projects = current_user.company.projects
                #@archived_projects = current_user.project_users.where(:archived => true).map(&:project).compact.uniq
            else
                @projects = current_user.project_users.where("archived = ?",false).map{|p| p.project if p.project.company_id == current_user.company_id}.compact.uniq
                @archived_projects = current_user.project_users.where(:archived => true).map(&:project).compact.uniq
            end
            
            @items = current_user.connect_items(nil)
            @companies = @items.map{|t| t.worklist.project.company}.uniq
        end
    end

end