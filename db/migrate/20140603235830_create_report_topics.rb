class CreateReportTopics < ActiveRecord::Migration
  def change
    create_table :report_topics do |t|
    	t.belongs_to :safety_topic
    	t.belongs_to :report
      	t.timestamps
    end
  end
end
