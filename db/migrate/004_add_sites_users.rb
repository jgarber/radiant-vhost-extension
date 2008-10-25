class AddSitesUsers < ActiveRecord::Migration
  def self.up
    create_table :sites_users, :id => false do |t|
      t.column :site_id, :integer
      t.column :user_id, :integer
    end
    
    add_index :sites_users, [:site_id, :user_id], :unique => true
    add_index :sites_users, :user_id
  end
  
  
  def self.down
    drop_table :sites_users
    remove_index :sites_users, [:site_id, :user_id]
    remove_index :sites_users, :user_id
  end
end