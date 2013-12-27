class AddWeatherAttributesToReport < ActiveRecord::Migration
  def change
  	add_column :reports, :weather_icon, :string
  	add_column :reports, :temp, :string
  	add_column :reports, :wind, :string
  end
end
