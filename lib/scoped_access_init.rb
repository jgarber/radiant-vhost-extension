##
##  scoped_access/init.rb handles Rails 1.2, 2.0, and 2.1, but the version
##  Radiant is using, 2.0.2, falls through the cracks. This fixes that.
##

ActionController::Base.instance_eval do
  def scoped_access (*args, &block)
    options = (Hash === args.last && !(args.last.keys & [:only, :except]).empty?) ? args.pop : {}
    send(:around_filter, ScopedAccess::Filter.new(*args, &block), options)
  end
end

require 'dispatcher'
# if ActionController.const_defined?(:Dispatcher)
#   # Rails2.1
#   ActionController::Dispatcher.class_eval do
#     class << self
#       def define_dispatcher_callbacks_with_reset(cache_classes)
#         define_dispatcher_callbacks_without_reset(cache_classes)
#         ScopedAccess.reset
#       end
#       alias_method_chain :define_dispatcher_callbacks, :reset
#    end
#   end
# 
# else
  # Rails1.2 or Rails2.0
  class ::Dispatcher
    app = respond_to?(:prepare_application, true) ? (class << self; self end) : self
    app.class_eval do
      private
      def prepare_application_with_reset
        ScopedAccess.reset
        prepare_application_without_reset
      end

      alias_method :prepare_application_without_reset, :prepare_application
      alias_method :prepare_application, :prepare_application_with_reset
    end
  end
# end

ActiveRecord::Base.instance_eval do
  def reset_scope
    scoped_methods.clear
  end
end
