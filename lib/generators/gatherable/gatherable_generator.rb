require 'rails/generators'
class GatherableGenerator < Rails::Generators::NamedBase
  source_root File.expand_path('../templates', __FILE__)
  def generate
    send "generate_#{file_name}"
  end

  private

  def generate_initialize
    copy_file "gatherable.rb", "config/initializers/gatherable.rb"
  end

  def schema_migration_created?
    Dir[File.join('db', 'migrate', "*create_gatherable_schema.rb")].present?
  end

  def generate_migrations
    MigrationWriter.write_schema_migration
    Gatherable.config.data_points.each do |data_point|
      MigrationWriter.new(data_point).write
    end
  end
end
