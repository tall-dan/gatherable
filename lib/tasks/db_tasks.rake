require 'pry'
namespace :db do
  task :prepare do
    Rails::Generators.invoke('gatherable', ['migrations'])
    ActiveRecord::Migrator.migrate "db/migrate"
  end
end
