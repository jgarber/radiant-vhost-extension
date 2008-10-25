module Ext
  module ApplicationHelper
    
    def self.included(receiver)
      receiver.send :alias_method_chain, :subtitle, :site_hostname
    end
    
    def subtitle_with_site_hostname
      current_site.hostname
    end
    
  end
end