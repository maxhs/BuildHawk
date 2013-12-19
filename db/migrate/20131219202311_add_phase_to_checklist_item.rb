class AddPhaseToChecklistItem < ActiveRecord::Migration
  def change
  	add_column :photos, :phase, :string
  end
end
