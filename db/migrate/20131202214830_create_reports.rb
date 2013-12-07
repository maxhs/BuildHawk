class CreateReports < ActiveRecord::Migration
  def change
    create_table :reports do |t|
      t.string :title
      t.string :body
      t.belongs_to :project
      t.belongs_to :user
      t.string :report_type
      t.timestamps
    end
  end
end
