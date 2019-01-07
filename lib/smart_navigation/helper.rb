module SmartNavigation
  module Helper
    def smart_navigation_for(items, options = {})
      SmartNavigation::Renderer.new(self, items, options).render
    end

    alias :navigation_for :smart_navigation_for
  end
end
