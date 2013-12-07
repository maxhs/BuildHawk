# app/controllers/registrations_controller.rb
class RegistrationsController < Devise::RegistrationsController
  def new
    super
  end

  def create
    # add custom create logic here
    @company = Company.where(name: params[:user][:company][:name]).first_or_create!
    @company.projects.build unless @company.projects.count
    super
    current_user.update_attribute :company_id, @company.id
  end

  def update
    super
  end
end 