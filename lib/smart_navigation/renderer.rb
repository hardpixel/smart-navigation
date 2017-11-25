module SmartNavigation
  class Renderer
    # Initialize builder
    def initialize(view_context, items, options={})
      @context              = view_context
      @items                = sort_items items
      @menu_class           = options.fetch :menu_class,           'menu'
      @sep_class            = options.fetch :separator_class,      'separator'
      @group_class          = options.fetch :group_class,          'menu-group'
      @submenu_class        = options.fetch :submenu_class,        'submenu'
      @active_class         = options.fetch :active_class,         'active'
      @active_submenu_class = options.fetch :active_submenu_class, 'open'
      @submenu_icons        = options.fetch :submenu_icons,        false
    end

    # Sort items by order
    def sort_items(items)
      items.sort_by { |_k, v| v[:order] }.to_h
    end

    # Get menu item url
    def item_url(item)
      params = { controller: item[:controller], action: item[:action] }
      params[:action] ? url_for(params) : "##{item[:id]}"
    end

    # Check if current page
    def current_page?(item)
      url = item_url(item)
      @context.current_page?(url)
    end

    # Check if current group
    def current_group?(item)
      current = item[:children].any? { |_k, v| current_page?(v) }
      current = item[:children].any? { |_k, v| current_group?(v) } if current.blank?
      current
    end

    # Create menu separator
    def separator_tag(item)
      content_tag :li, item[:label], class: @sep_class
    end

    # Create item link
    def item_link_tag(item, icons=false)
      arrow = content_tag :span, icon('angle-left pull-right'), class: 'pull-right-container'
      label = content_tag :span, item[:label]
      label = icon("#{item[:icon]}") + label if icons.present?
      label = label + arrow if item[:children].present?

      link_to label.html_safe, item_url(item)
    end

    # Create submenu item
    def submenu_item_tag(item, active=false)
      items  = sort_items item[:children]
      items  = items.map { |_k, v| item_tag(v, @submenu_icons) }.join
      active = @active_submenu_class if active.present?

      content_tag(:ul, items.html_safe, class: "#{active} #{@submenu_class}")
    end

    # Create group menu item
    def group_item_tag(item, icons=false)
      active  = @active_class if current_group?(item)
      link    = item_link_tag item, icons
      submenu = submenu_item_tag item, active
      content = link + submenu

      content_tag :li, content.html_safe, class: "#{active} #{@group_class}"
    end

    # Create single menu item
    def single_item_tag(item, icons=false)
      active = @active_class if current_page?(item)
      link   = item_link_tag(item, icons)

      content_tag :li, link.html_safe, class: "#{active}"
    end

    # Create menu list item
    def item_tag(item, icons=false)
      if item[:separator].present?
        separator_tag(item)
      elsif item[:children].present?
        group_item_tag(item, icons)
      else
        single_item_tag(item, icons)
      end
    end

    # Create menu list
    def menu_tag(items)
      content_tag :ul, items.html_safe, class: @menu_class
    end

    # Render menu
    def render
      menu_tag @items.map { |k, v| item_tag(v, true) }.join
    end

    # Get app helpers if method is missing
    def method_missing(method, *args, &block)
      @context.respond_to?(method) ? @context.send(method, *args, &block) : super
    end
  end
end
