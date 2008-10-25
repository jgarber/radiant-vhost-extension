module Ext
  module Admin::AbstractModelController
    def self.included(receiver)
      receiver.send :before_filter, :ensure_user_has_site_access
    end
    
    def ensure_user_has_site_access
      unless current_site.allow_access_for(current_user)
        flash[:error] = 'Access denied.'
        redirect_to :controller => 'welcome', :action => 'login'
      end
    end
  end
end