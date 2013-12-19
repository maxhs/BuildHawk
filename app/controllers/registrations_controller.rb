# app/controllers/registrations_controller.rb
class RegistrationsController < Devise::RegistrationsController
  def new
    super
  end

  def create
    # add custom create logic here
    super
    @company = Company.where(name: params[:user][:company][:name]).first_or_create!
    @company.projects.build unless @company.projects.count
    current_user.update_attribute :company_id, @company.id
    if @company.users.first.id == current_user.id
        current_user.update_attribute :admin, true
      end
  end

  def update
    super
  end
end 