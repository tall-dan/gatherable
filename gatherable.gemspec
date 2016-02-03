$:.push File.expand_path('../lib', __FILE__)

# Maintain your gem's version:
require 'gatherable/version'

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name        = 'gatherable'
  s.version     = Gatherable::VERSION
  s.authors     = ['Daniel Schepers']
  s.email       = ['schepedw@gmail.com']
  s.homepage    = 'https://github.com/schepedw/gatherable'
  s.summary     = 'Painlessly gather and store data'
  s.description = 'Dynamically define models, controllers, and routes'
  s.license     = 'MIT'

  s.files = Dir['{app,config,db,lib}/**/*', 'MIT-LICENSE', 'Rakefile', 'README.rdoc']
  s.test_files = Dir['spec/**/*']

  s.add_dependency 'rails', '>= 4.0.0'

  s.add_development_dependency 'pg', '~> 0.18'
  s.add_development_dependency 'pry', '~> 0.10'
  s.add_development_dependency 'rake', '>= 10.0.0'
  s.add_development_dependency 'rspec-rails', '~> 3.4.0'
  s.add_development_dependency 'codeclimate-test-reporter', '0.4.8'
end
