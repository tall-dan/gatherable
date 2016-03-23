namespace :db do
  ROLE='gatherable'
  task :prepare do
    require 'rails/generators'
    old_dir = Dir.pwd
    Dir.chdir(Rails.root)
    Rails::Generators.invoke('gatherable', ['migrations'])
    ActiveRecord::Migrator.migrate "db/migrate"
    Dir.chdir(old_dir)
  end

  task :setup do
    db_name = "#{ROLE}_#{ENV['RAILS_ENV'] || 'test'}"
    sh "createuser --createdb --login #{ROLE}|| echo"
    sh "createdb #{db_name} -O #{ROLE }|| echo"
  end
end
