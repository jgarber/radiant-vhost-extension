module SiteScope
  def self.included(receiver)
    receiver.send :helper_method, :current_site
  end
  
  def current_site
    @current_site ||= Site.find_by_hostname(request.host) || Site.find_by_hostname('*')
    raise "No site found to match #{request.host}." unless @current_site
    @current_site
  end

  protected
  def site_scope
    @site_scope ||= {
      :find => { :conditions => ["site_id = ?", current_site.id]},
      :create => { :site_id => current_site.id }
    }
  end
  
  def set_site_scope_in_models
    VhostExtension::SITE_SPECIFIC_MODELS.each do |model|
      model.constantize.current_site = self.current_site
    end
  end
  
end