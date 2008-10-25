namespace :radiant do
  namespace :extensions do
    namespace :vhost do
      
      desc "Runs the migration of the Vhost extension"
      task :migrate => :environment do
        require 'radiant/extension_migrator'
        if ENV["VERSION"]
          VhostExtension.migrator.migrate(ENV["VERSION"].to_i)
        else
          VhostExtension.migrator.migrate
        end
      end
    
    end
  end
end

Rake::TaskManager.class_eval do
  def remove_task(task_name)
    @tasks.delete(task_name.to_s)
  end
end
 
def remove_task(task_name)
  Rake.application.remove_task(task_name)
end

# We need the bootstrap task to use site_ids
remove_task "db:bootstrap"
remove_task "db:remigrate"
namespace :db do  
  desc "Bootstrap your database for Radiant."
  task :bootstrap => :remigrate do
    require 'radiant/setup'
    require File.join(File.dirname(__FILE__), '../bootstrap_with_site_id')
    Radiant::Setup.send :include, BootstrapWithSiteId
    Radiant::Setup.send :alias_method_chain, :load_database_template, :site_id
    
    Radiant::Setup.bootstrap(
      :admin_name => ENV['ADMIN_NAME'],
      :admin_username => ENV['ADMIN_USERNAME'],
      :admin_password => ENV['ADMIN_PASSWORD'],
      :database_template => ENV['DATABASE_TEMPLATE']
    )
  end
  
  desc "Migrate schema to version 0 and back up again. WARNING: Destroys all data in tables!!"
  task :remigrate => :environment do
    require 'highline/import'
    require 'radiant/extension_migrator'
    if ENV['OVERWRITE'].to_s.downcase == 'true' or
      agree("This task will destroy any data in the database. Are you sure you want to \ncontinue? [yn] ")
      
      # Migrate extensions downward
      Radiant::Extension.descendants.each do |ext|
        ext.migrator.migrate(0)
      end
      
      # Migrate downward
      ActiveRecord::Migrator.migrate("#{RADIANT_ROOT}/db/migrate/", 0)
    
      # Migrate upward 
      Rake::Task["db:migrate"].invoke
      
      # Migrate extensions upward
      Radiant::ExtensionMigrator.migrate_extensions
      
      # Dump the schema
      Rake::Task["db:schema:dump"].invoke
    else
      say "Task cancelled."
      exit
    end
  end
end