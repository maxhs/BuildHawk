class CreateBillingDays < ActiveRecord::Migration
  def change
    create_table :billing_days do |t|
      t.belongs_to :user
      t.belongs_to :project
      t.timestamps
    end
  end
end
