# frozen_string_literal: true

require File.expand_path('lib/altadata/version', __dir__)

Gem::Specification.new do |spec|
  spec.name                  = 'altadata'
  spec.version               = Altadata::VERSION
  spec.authors               = ['ALTADATA']
  spec.email                 = ['contact@altadata.io']
  spec.summary               = 'Ruby gem for the ALTADATA API'
  spec.description           = 'ALTADATA Ruby gem provides convenient access to the ALTADATA API from applications written in the Ruby language.'
  spec.homepage              = 'https://github.com/altabering/altadata-ruby'
  spec.license               = 'MIT'
  spec.platform              = Gem::Platform::RUBY
  spec.required_ruby_version = Gem::Requirement.new('>= 2.5.0')

  spec.files = Dir['README.md', 'LICENSE', 'CHANGELOG.md', 'lib/**/*.rb', 'lib/**/*.rake',
                   'altadata.gemspec', '.github/*.md', 'Gemfile', 'Rakefile']
  spec.test_files       = Dir['spec/**/*.rb']
  spec.extra_rdoc_files = ['README.md']
  spec.require_paths    = ['lib']

  spec.add_dependency 'faraday',                              '~> 1.0'
  spec.add_dependency 'json',                                 '>= 1.8.0'

  spec.add_development_dependency 'rake',                     '~> 13.0'
  spec.add_development_dependency 'rspec',                    '~> 3.6'
  spec.add_development_dependency 'rubocop',                  '~> 1.1'
  spec.add_development_dependency 'rubocop-performance',      '~> 1.5'
  spec.add_development_dependency 'rubocop-rspec',            '~> 1.37'
end
