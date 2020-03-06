lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'smart_navigation/version'

Gem::Specification.new do |spec|
  spec.name          = 'smart_navigation'
  spec.version       = SmartNavigation::VERSION
  spec.authors       = ['Jonian Guveli']
  spec.email         = ['jonian@hardpixel.eu']
  spec.summary       = %q{View helpers for navigation menus}
  spec.description   = %q{View helpers for navigation menus. Build navigation menus from hash objects.}
  spec.homepage      = 'https://github.com/hardpixel/smart-navigation'
  spec.license       = 'MIT'
  spec.files         = Dir['{lib/**/*,[A-Z]*}']
  spec.bindir        = 'exe'
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ['lib']

  spec.add_dependency 'actionview', '~> 5.0'

  spec.add_development_dependency 'bundler', '~> 1.14'
  spec.add_development_dependency 'rake', '~> 13.0'
  spec.add_development_dependency 'minitest', '~> 5.0'
end
