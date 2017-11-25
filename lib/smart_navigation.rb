require 'active_support'
require 'smart_navigation/version'

module SmartNavigation
  extend ActiveSupport::Autoload

  # Autoload modules
  autoload :Renderer
  autoload :Helper
end

# Include action view helpers
if defined? ActionView::Base
  ActionView::Base.send :include, SmartNavigation::Helper
end
