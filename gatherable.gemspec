$:.push File.expand_path('../lib', __FILE__)

# Maintain your gem's version:
require 'gatherable/version'

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name        = 'gatherable'
  s.version     = Gatherable::VERSION
  s.authors     = ['Daniel Schepers']
  s.email       = ['schepedw@gmail.com']
  s.homepage    = 'TODO'
  s.summary     = 'TODO: Summary of Gatherable.'
  s.description = 'TODO: Description of Gatherable.'
  s.license     = 'MIT'

  s.files = Dir['{app,config,db,lib}/**/*', 'MIT-LICENSE', 'Rakefile', 'README.rdoc']
  s.test_files = Dir['test/**/*']

  s.add_dependency 'rails', '>= 3.0.0'
  #how do we deal with db dependencies? don't? :)

  s.add_development_dependency 'pg'
  s.add_development_dependency 'pry'
end
