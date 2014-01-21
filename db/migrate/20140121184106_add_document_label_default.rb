class AddDocumentLabelDefault < ActiveRecord::Migration
  def change
  	change_column :photos, :source, :string, :default => "Documents"
  end
end
