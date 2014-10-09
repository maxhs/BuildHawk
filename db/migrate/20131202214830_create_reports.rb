class CreateReports < ActiveRecord::Migration
  def change
    create_table :reports do |t|
      t.string :title
      t.text :body
      t.belongs_to :project
      t.belongs_to :author, :class_name => "User"
      t.string :report_type
      t.text :weather
      t.string :humidity
      t.string :precip_accumulation
      t.string :precip
      t.string :date_string
      t.timestamps
    end
  end
end
