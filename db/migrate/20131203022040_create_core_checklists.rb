class CreateCoreChecklists < ActiveRecord::Migration
  def change
    create_table :core_checklists do |t|

      t.timestamps
    end
  end
end
