class AddMobileFlag < ActiveRecord::Migration
  def change
  	add_column :reports, :mobile, :boolean, :default => false
  	add_column :tasks, :mobile, :boolean, :default => false
  	add_column :comments, :mobile, :boolean, :default => false
  	add_column :photos, :mobile, :boolean, :default => false
  end
end
