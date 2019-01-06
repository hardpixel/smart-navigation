require 'active_support'
require 'smart_navigation/version'

module SmartNavigation
  extend ActiveSupport::Autoload

  autoload :Renderer
  autoload :Helper
end

if defined? ActionView::Base
  ActionView::Base.send :include, SmartNavigation::Helper
end
