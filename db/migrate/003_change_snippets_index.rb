class ChangeSnippetsIndex < ActiveRecord::Migration
  def self.up
    remove_index "snippets", :name => "name"
    add_index :snippets, [:name, :site_id]
  end
  
  
  def self.down
    add_index "snippets", ["name"], :name => "name", :unique => true
    remove_index :snippets, :column => :name
  end
end