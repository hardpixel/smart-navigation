module SmartNavigation
  class Renderer
    # Initialize builder
    def initialize(view_context, items, options={})
      @context = view_context
      @items   = sort_items items
      @options = merge_options options
    end

    # Render menu
    def render
      menu_tag @items.map { |k, v| item_tag(v, @options[:menu_icons]) }.join
    end

    private

      # Default options
      def default_options
        {
          menu_class:           'menu',
          menu_html:            {},
          menu_icons:           true,
          separator_class:      'separator',
          submenu_parent_class: 'has-submenu',
          submenu_class:        'submenu',
          active_class:         'active',
          active_submenu_class: 'open',
          submenu_icons:        false,
          submenu_toggle:       nil,
          icon_prefix:          'icon icon-',
          icon_default:         'missing',
          icon_position:        'left',
          keep_defaults:        true
        }
      end

      # Get merged options
      def merge_options(options)
        if @options[:keep_defaults].present?
          default_options.merge(options)
        else
          options
        end
      end

      # Sort items by order
      def sort_items(items)
        items.sort_by { |_k, v| v[:order] }.to_h
      end

      # Get menu item url
      def item_url(item)
        if item[:url].present?
          mixed_value(item[:url])
        elsif item[:id].present?
          "##{item[:id]}"
        end
      end

      # Check if should render item
      def render_item?(item)
        if item[:if]
          mixed_value(item[:if]).present?
        elsif item[:unless]
          mixed_value(item[:unless]).blank?
        else
          true
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

      # Create html tag
      def tag(*args, &block)
        @context.content_tag(*args, &block)
      end

      # Create menu icon
      def icon_tag(name, label=nil)
        icon = tag :i, nil, class: "#{@options[:icon_prefix]}#{name || @options[:icon_default]}"

        if @options[:icon_position] == 'left'
          "#{icon}#{label}".html_safe
        else
          "#{label}#{icon}".html_safe
        end
      end

      # Create submenu toggle tag
      def toggle_tag
        "#{@options[:submenu_toggle]}".html_safe
      end

      # Create menu separator
      def separator_tag(item)
        tag :li, item[:label], class: @options[:separator_class]
      end

      # Create item link
      def item_link_tag(item, icons=false)
        label = tag :span, item[:label]
        label = icon_tag("#{item[:icon]}", label) if icons.present?
        label = label + toggle_tag if item[:children].present?
        url   = item_url(item)

        if url.nil?
          tag :a, label.html_safe, Hash(item[:html])
        else
          @context.link_to label.html_safe, url, Hash(item[:html])
        end
      end

      # Create submenu item
      def submenu_item_tag(item, active=false)
        items  = sort_items item[:children]
        items  = items.map { |_k, v| item_tag(v, @options[:submenu_icons]) }.join
        active = @options[:active_submenu_class] if active.present?

        tag(:ul, items.html_safe, class: "#{active} #{@options[:submenu_class]}".strip)
      end

      # Create group menu item
      def group_item_tag(item, icons=false)
        active  = @options[:active_class] if current_group?(item)
        link    = item_link_tag item, icons
        submenu = submenu_item_tag item, active
        content = link + submenu

        tag :li, content.html_safe, class: "#{active} #{@options[:submenu_parent_class]}".strip
      end

      # Create single menu item
      def single_item_tag(item, icons=false)
        active = @options[:active_class] if current_page?(item)
        link   = item_link_tag(item, icons)

        tag :li, link.html_safe, class: "#{active}"
      end

      # Create menu list item
      def item_tag(item, icons=false)
        if render_item?(item)
          if item[:separator].present?
            separator_tag(item)
          elsif item[:children].present?
            group_item_tag(item, icons)
          else
            single_item_tag(item, icons)
          end
        end
      end

      # Create menu list
      def menu_tag(items)
        tag :ul, items.html_safe, Hash(@options[:menu_html]).merge(class: @options[:menu_class])
      end

      # Parse mixed value
      def mixed_value(value)
        if value.is_a?(Proc)
          @context.instance_exec(&value)
        elsif value.is_a?(Symbol)
          @context.send(value)
        else
          value
        end
      end
  end
end
