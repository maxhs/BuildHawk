class AddDefaultToProjectOrderIndex < ActiveRecord::Migration
  def change
  	change_column :projects, :order_index, :integer, default:0
  end
end
