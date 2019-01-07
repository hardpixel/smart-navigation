module SmartNavigation
  class Renderer
    def initialize(view_context, items, options = {})
      @context = view_context
      @items   = sort_items items
      @options = merge_options options
    end

    def render
      menu_tag @items.map { |k, v| item_tag(v, @options[:menu_icons]) }.join
    end

    private

    def default_options
      {
        menu_class:           'menu',
        menu_html:            {},
        menu_icons:           true,
        item_class:           'menu-item',
        separator_class:      'separator',
        submenu_parent_class: 'has-submenu',
        submenu_class:        'submenu',
        submenu_item_class:   'submenu-item',
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

    def merge_options(options)
      if options[:keep_defaults] == false
        options
      else
        default_options.merge(options)
      end
    end

    def sort_items(items)
      items.sort_by { |_k, v| v[:order] }.to_h
    end

    def page_parent?(item)
      url   = item_url item
      paths = [@context.request.path, @context.request.url]

      url.present? && item[:root].blank? && paths.any? { |i| i.starts_with?(url) }
    end

    def item_url(item)
      if item[:url].present?
        mixed_value(item[:url])
      elsif item[:id].present?
        "##{item[:id]}"
      end
    end

    def render_item?(item)
      if item[:if]
        mixed_value(item[:if]).present?
      elsif item[:unless]
        mixed_value(item[:unless]).blank?
      else
        true
      end
    end

    def current_page?(item)
      current = @context.current_page?(item_url(item))
      current = page_parent?(item) if item[:children].blank? and current.blank?

      current
    end

    def current_group?(item)
      current = current_page?(item)
      current = Hash(item[:children]).any? { |_k, v| current_page?(v) } if current.blank?
      current = Hash(item[:children]).any? { |_k, v| current_group?(v) } if current.blank?

      current
    end

    def tag(*args, &block)
      @context.content_tag(*args, &block)
    end

    def icon_tag(name, label = nil)
      icon = tag :i, nil, class: "#{@options[:icon_prefix]}#{name || @options[:icon_default]}"

      if @options[:icon_position] == 'left'
        "#{icon}#{label}".html_safe
      else
        "#{label}#{icon}".html_safe
      end
    end

    def toggle_tag
      "#{@options[:submenu_toggle]}".html_safe
    end

    def separator_tag(item)
      tag :li, item[:label], class: @options[:separator_class]
    end

    def item_link_tag(item, icons = false)
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

    def submenu_item_tag(item, active = false)
      items  = sort_items item[:children]
      items  = items.map { |_k, v| item_tag(v, @options[:submenu_icons], true) }.join
      active = @options[:active_submenu_class] if active.present?

      tag(:ul, items.html_safe, class: "#{active} #{@options[:submenu_class]}".strip)
    end

    def group_item_tag(item, icons = false)
      active  = @options[:active_class] if current_group?(item)
      link    = item_link_tag item, icons
      submenu = submenu_item_tag item, active
      content = link + submenu

      tag :li, content.html_safe, class: "#{active} #{@options[:submenu_parent_class]}".strip
    end

    def single_item_tag(item, icons = false, subitem = false)
      active = @options[:active_class] if current_page?(item)
      iclass = subitem ? @options[:submenu_item_class] : @options[:item_class]
      link   = item_link_tag(item, icons)
      opts   = Hash(item[:wrapper_html])
      opts   = opts.merge(class: "#{opts[:class]} #{active} #{iclass}".strip)

      tag :li, link.html_safe, opts
    end

    def item_tag(item, icons = false, subitem = false)
      if render_item?(item)
        if item[:separator].present?
          separator_tag(item)
        elsif item[:children].present?
          group_item_tag(item, icons)
        else
          single_item_tag(item, icons, subitem)
        end
      end
    end

    def menu_tag(items)
      tag :ul, items.html_safe, Hash(@options[:menu_html]).merge(class: @options[:menu_class])
    end

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
