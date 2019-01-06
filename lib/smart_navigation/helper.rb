module SmartNavigation
  module Helper
    # Render navigation builder
    def smart_navigation_for(items, options = {})
      SmartNavigation::Renderer.new(self, items, options).render
    end

    # Alias helper method
    alias :navigation_for :smart_navigation_for
  end
end
