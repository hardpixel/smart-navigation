# SmartNavigation

View helpers for navigation menus. Build navigation menus from hash objects.

[![Gem Version](https://badge.fury.io/rb/smart_navigation.svg)](https://badge.fury.io/rb/smart_navigation)
[![Build Status](https://travis-ci.org/hardpixel/smart-navigation.svg?branch=master)](https://travis-ci.org/hardpixel/smart-navigation)
[![Maintainability](https://api.codeclimate.com/v1/badges/c484472c3989ff4a7c33/maintainability)](https://codeclimate.com/github/hardpixel/smart-navigation/maintainability)

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'smart_navigation'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install smart_navigation

## Usage

Define the menu items in a hash:

```ruby
@items = {
  dashboard: {
    label: 'Dashboard',
    url:   :root_path,
    icon:  'dashboard',
    html:  { target: :_blank }
  },
  pages: {
    label: 'Pages',
    url:   :admin_pages_path,
    icon:  'pages',
    children: {
      index: {
        label: 'All Pages',
        url:   :pages_path
      },
      new: {
        label: 'New Page',
        url:   :new_page_path
      }
    }
  },
  system: {
    label:     'System',
    separator: true
  },
  profile: {
    label: 'Profile',
    url:   -> { edit_user_path(current_user) },
    icon:  'user',
    if:    :user_signed_in?
  }
}
```

The `url` key can be a String, a Symbol or a Proc. Keys `if` and `unless` can be a Symbol or a Proc. Symbols and Procs are executed in the view context.

To render a menu you can use the `navigation_for` or `smart_navigation_for` helper in your views:

```erb
<%= smart_navigation_for(@items) %>
```

There are a number of options you can use to customize the navigation. The default options are:

```ruby
options = {
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
  icon_position:        'left',
  keep_defaults:        true
}

smart_navigation_for(@items, options)
```

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake test` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment. To install this gem onto your local machine, run `bundle exec rake install`.

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/hardpixel/smart-navigation. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [Contributor Covenant](http://contributor-covenant.org) code of conduct.

## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).

## Code of Conduct

Everyone interacting in the SmartNavigation project’s codebases, issue trackers, chat rooms and mailing lists is expected to follow the [code of conduct](https://github.com/hardpixel/smart-navigation/blob/master/CODE_OF_CONDUCT.md).
