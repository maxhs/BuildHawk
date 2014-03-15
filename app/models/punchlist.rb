class Punchlist < ActiveRecord::Base
	attr_accessible :name, :project_id, :active, :worklist
  	
  	has_many :punchlist_items, :dependent => :destroy
  	belongs_to :project

    def personnel
      (punchlist_items.map(&:sub_assignee).flatten + punchlist_items.map(&:assignee).flatten).uniq.compact
    end

	acts_as_api

  	api_accessible :user do |t|
  		t.add :punchlist_items
      t.add :personnel
  	end

  	api_accessible :projects do |t|
  		t.add :punchlist_items
      t.add :personnel
  	end

    api_accessible :punchlist do |t|
      t.add :punchlist_items
      t.add :personnel
    end
end
