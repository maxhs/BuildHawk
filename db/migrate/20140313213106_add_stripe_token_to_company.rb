class AddStripeTokenToCompany < ActiveRecord::Migration
  def change
  	remove_column :companies, :valid_billing, :boolean
  	add_column :companies, :customer_token, :string
  end
end
