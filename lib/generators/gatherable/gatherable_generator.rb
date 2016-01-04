require 'rails/generators'
class GatherableGenerator < Rails::Generators::NamedBase
  source_root File.expand_path('../templates', __FILE__)
  def generate
    send "generate_#{file_name}"
  end

  private

  def generate_initializer
    copy_file "gatherable.rb", "config/initializers/gatherable.rb"
  end

  def generate_migrations
    MigrationWriter.write_schema_migration
    Gatherable.config.data_points.each do |data_point|
      MigrationWriter.new(data_point).write
    end
  end

  def generate_models
    Gatherable.config.data_points.each do |data_point|
      ModelWriter.new(data_point).write
    end
  end

  def generate_controllers
    copy_file 'application_controller.rb', 'app/controllers/gatherable/application_controller.rb'
    Gatherable.config.data_points.each do |data_point|
      ControllerWriter.new(data_point).write
    end
  end
end
