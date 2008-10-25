class AddSiteColumns < ActiveRecord::Migration
  
  SITE_SPECIFIC_MODELS = %w(Layout Page Snippet)
  
  # Declare the models so we can use them.
  SITE_SPECIFIC_MODELS.each do |model|
    eval "class #{model} < ActiveRecord::Base; end"
  end
  
  def self.up
    SITE_SPECIFIC_MODELS.each do |model|
      add_column model.tableize, :site_id, :integer
      model.constantize.update_all "site_id = 1"
    end
  end

  def self.down
    SITE_SPECIFIC_MODELS.each do |model|
      remove_column model.tableize, :site_id
    end
  end
end