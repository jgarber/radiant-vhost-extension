# Uncomment this if you reference any of your controllers in activate
require_dependency 'application'
require File.join(File.dirname(__FILE__), 'vendor/scoped_access/init')
require File.join(File.dirname(__FILE__), 'vendor/scoped_access/lib/scoped_access')



class VhostExtension < Radiant::Extension
  version "1.0"
  description "Describe your extension here"
  url "http://yourwebsite.com/vhost"
  
  SITE_SPECIFIC_MODELS = %w(Layout Page Snippet)
  
  define_routes do |site|
    site.site_index   'admin/sites',            :controller => 'admin/site', :action => 'index'
    site.site_edit    'admin/sites/edit/:id',   :controller => 'admin/site', :action => 'edit'
    site.site_new     'admin/sites/new',        :controller => 'admin/site', :action => 'new'
    site.site_remove  'admin/sites/remove/:id', :controller => 'admin/site', :action => 'remove'
  end
  
  def activate
    admin.tabs.add "Sites", "/admin/sites", :after => "Layouts", :visibility => [:admin]

    ApplicationController.send :include, SiteScope
    SITE_SPECIFIC_MODELS.each do |model|
      ApplicationController.send :around_filter, ScopedAccess::Filter.new(model.constantize, :site_scope)
      model.constantize.send :cattr_accessor, :current_site
    end
    ApplicationController.send :before_filter, :set_site_scope_in_models
    ApplicationController.send :observer, :site_association_observer
    
    
    SiteController.send :alias_method, :show_page_orig, :show_page
    # SiteController.send :alias_method, :show_uncached_page_orig, :show_uncached_page
    SiteController.send :remove_method, :show_page
    # SiteController.send :remove_method, :show_uncached_page
    SiteController.send :include, CacheByDomain
    
    require_dependency 'redo_validations'
    
    ApplicationHelper.send :include, Ext::ApplicationHelper
    Admin::AbstractModelController.send :include, Ext::Admin::AbstractModelController
    Admin::PageController.send :include, Ext::Admin::PageController
  end
  
  def deactivate
    # admin.tabs.remove "Vhost"
  end
  
end