class AddHumidityToReports < ActiveRecord::Migration
  def change
  	add_column :reports, :humidity, :string
  	add_column :reports, :precip_accumulation, :string
  end
end
