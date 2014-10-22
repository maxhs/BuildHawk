class AppController < ApplicationController
	before_filter :user_projects
	layout 'app'

    def user_projects
        if user_signed_in?# && params[:reload]
            if current_user.any_admin?
                @sidebar_projects = current_user.company.projects.where("hidden = ? and project_group_id IS NULL",false).order('order_index')
                @projects = current_user.company.projects.where(core: false)
            else
                @sidebar_projects = current_user.project_users.where("hidden = ? and project_group_id IS NULL",false).map{|p| p.project if p.project.company_id == current_user.company_id}.compact.uniq.sort_by(&:order_index)
                @projects = current_user.project_users.where("hidden = ?",false).map{|p| p.project if p.project.company_id == current_user.company_id}.compact.uniq.sort_by(&:order_index)
            end
        
            @hidden_projects = current_user.project_users.where(hidden: true).map(&:project).compact.uniq     
            @demo_projects = Project.where(core: true)
            @project_groups = current_user.company.project_groups if current_user.company
            tasks = current_user.connect_tasks(nil)
            @companies = tasks.map{|t| t.tasklist.project.company}.compact.uniq if tasks && tasks.count > 0
        end
    end

end