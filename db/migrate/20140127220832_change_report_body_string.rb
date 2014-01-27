class ChangeReportBodyString < ActiveRecord::Migration
  def change
  	change_column :reports, :body, :text
  	change_column :apn_registrations, :token, :text
  end
end
