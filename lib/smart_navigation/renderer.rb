module SmartNavigation
  class Renderer
    # Initialize builder
    def initialize(view_context, items, options={})
      @context              = view_context
      @items                = sort_items items
      @menu_class           = options.fetch :menu_class,           'menu'
      @menu_html            = options.fetch :menu_html,            {}
      @sep_class            = options.fetch :separator_class,      'separator'
      @submenu_parent_class = options.fetch :submenu_parent_class, 'has-submenu'
      @submenu_class        = options.fetch :submenu_class,        'submenu'
      @active_class         = options.fetch :active_class,         'active'
      @active_submenu_class = options.fetch :active_submenu_class, 'open'
      @submenu_icons        = options.fetch :submenu_icons,        false
      @submenu_toggle       = options.fetch :submenu_toggle,       nil
      @icon_helper          = options.fetch :icon_helper,          false
      @icon_prefix          = options.fetch :icon_prefix,          'icon icon-'
      @icon_position        = options.fetch :icon_position,        'left'
    end

    # Sort items by order
    def sort_items(items)
      items.sort_by { |_k, v| v[:order] }.to_h
    end

    # Get menu item url
    def item_url(item)
      value = item[:url]

      if value.present?
        if value.is_a?(Proc)
          @context.instance_exec(&value)
        elsif value.is_a?(Symbol)
          @context.send(value)
        else
          value
        end
      else
        "##{item[:id]}"
      end
    end

    # Check if current page
    def current_page?(item)
      url = item_url(item)
      @context.current_page?(url)
    end

    # Check if current group
    def current_group?(item)
      current = true if current_page?(item)
      current = Hash(item[:children]).any? { |_k, v| current_page?(v) } if current.blank?
      current = Hash(item[:children]).any? { |_k, v| current_group?(v) } if current.blank?
      current
    end

    # Create menu icon
    def icon_tag(name, label=nil)
      if @icon_helper.present?
        icon = @context.send(@icon_helper, name)
      else
        icon = content_tag :i, nil, class: "#{@icon_prefix}#{name}"
      end

      @icon_position == 'left' ? "#{icon}#{label}".html_safe : "#{label}#{icon}".html_safe
    end

    # Create submenu toggle tag
    def toggle_tag
      "#{@submenu_toggle}".html_safe
    end

    # Create menu separator
    def separator_tag(item)
      content_tag :li, item[:label], class: @sep_class
    end

    # Create item link
    def item_link_tag(item, icons=false)
      label = content_tag :span, item[:label]
      label = icon_tag("#{item[:icon]}", label) if icons.present?
      label = label + toggle_tag if item[:children].present?

      link_to label.html_safe, item_url(item)
    end

    # Create submenu item
    def submenu_item_tag(item, active=false)
      items  = sort_items item[:children]
      items  = items.map { |_k, v| item_tag(v, @submenu_icons) }.join
      active = @active_submenu_class if active.present?

      content_tag(:ul, items.html_safe, class: "#{active} #{@submenu_class}".strip)
    end

    # Create group menu item
    def group_item_tag(item, icons=false)
      active  = @active_class if current_group?(item)
      link    = item_link_tag item, icons
      submenu = submenu_item_tag item, active
      content = link + submenu

      content_tag :li, content.html_safe, class: "#{active} #{@submenu_parent_class}".strip
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
      content_tag :ul, items.html_safe, Hash(@menu_html).merge(class: @menu_class)
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
