class SiteAssociationObserver < ActiveRecord::Observer
  observe *VhostExtension::SITE_SPECIFIC_MODELS.collect(&:constantize)
  
  def before_validation(model)
    model.site_id ||= model.class.current_site.id
  end
end