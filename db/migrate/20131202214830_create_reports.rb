class CreateReports < ActiveRecord::Migration
  def change
    create_table :reports do |t|
      t.string :title
      t.string :body
      t.belongs_to :project
      t.belongs_to :author, :class_name => "User"
      t.string :report_type
      t.text :weather
      t.timestamps
    end
  end
end
