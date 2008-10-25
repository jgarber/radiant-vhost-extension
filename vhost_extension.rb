require_dependency 'application'
require File.join(File.dirname(__FILE__), 'lib/scoped_access_init')
require File.join(File.dirname(__FILE__), 'vendor/scoped_access/lib/scoped_access')


class VhostExtension < Radiant::Extension
  version "2.0"
  description "Host multiple sites on a single instance."
  url "http://github.com/jgarber/radiant-vhost-extension"
  
  SITE_SPECIFIC_MODELS = %w(Layout Page Snippet)
  
  define_routes do |site|
    site.site_index   'admin/sites',            :controller => 'admin/site', :action => 'index'
    site.site_edit    'admin/sites/edit/:id',   :controller => 'admin/site', :action => 'edit'
    site.site_new     'admin/sites/new',        :controller => 'admin/site', :action => 'new'
    site.site_remove  'admin/sites/remove/:id', :controller => 'admin/site', :action => 'remove'
  end
  
  def activate
    admin.tabs.add "Sites", "/admin/sites", :after => "Layouts", :visibility => [:admin]
    
    Radiant::AdminUI.class_eval do
      attr_accessor :site
    end
    admin.site = load_default_site_regions

    ApplicationController.send :include, SiteScope
    SITE_SPECIFIC_MODELS.each do |model|
      ApplicationController.send :around_filter, ScopedAccess::Filter.new(model.constantize, :site_scope)
      model.constantize.send :cattr_accessor, :current_site
    end
    ApplicationController.send :before_filter, :set_site_scope_in_models
    SiteAssociationObserver.instance
    
    
    SiteController.send :alias_method, :show_page_orig, :show_page
    SiteController.send :remove_method, :show_page
    SiteController.send :include, CacheByDomain
    
    require_dependency 'redo_validations'
    
    ApplicationHelper.send :include, Ext::ApplicationHelper
    Admin::AbstractModelController.send :include, Ext::Admin::AbstractModelController
    Admin::PageController.send :include, Ext::Admin::PageController
  end
  
  def deactivate
    admin.tabs.remove "Sites"
  end
  
  private
  
  def load_default_site_regions
    returning OpenStruct.new do |site|
      site.edit = Radiant::AdminUI::RegionSet.new do |edit|
        edit.main.concat %w{edit_header edit_form}
        edit.form.concat %w{edit_hostname edit_users}
        edit.form_bottom.concat %w{edit_buttons}
      end
    end
  end
  
end