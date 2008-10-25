class ChangeSnippetsIndex < ActiveRecord::Migration
  def self.up
    add_index :snippets, [:name, :site_id]
  end
  
  
  def self.down
    remove_index :snippets, :column => [:name, :site_id]
  end
end