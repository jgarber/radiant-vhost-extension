module Ext
  module Admin::PageController
    def self.included(receiver)
      receiver.send :alias_method_chain, :clear_model_cache, :site_specificity
    end
    
    def clear_model_cache_with_site_specificity
      if respond_to?(:current_site)
        host_to_expire = current_site.hostname == '*' ? request.host : current_site.hostname
      else
        host_to_expire = request.host
      end
      url_to_expire = "#{host_to_expire}/#{@page.url}"
      @cache.expire_response(url_to_expire)
    end
  end
end