class CleanUp < ActiveRecord::Migration
  def change
  	drop_table :promo_codes
  	drop_table :subs
  	drop_table :report_subs
  end
end
