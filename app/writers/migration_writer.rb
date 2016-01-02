class MigrationWriter
  attr_reader :data_point

  def initialize(data_point)
    @data_point = data_point
  end

  def self.write_schema_migration
    FileUtils.mkdir_p('db/migrate')
    return if schema_migration_created?
    File.open(schema_migration, 'w') do |f|
      f.puts <<-schema_migration
class CreateGatherableSchema < ActiveRecord::Migration
  def up
    create_schema 'gatherable'
  end

  def down
    drop_schema 'gatherable'
  end
end
      schema_migration
    end
    puts "created #{schema_migration}"
  end

  def write
    if matching_migrations.present?
      puts already_found_message
      return
    end
    filename = "db/migrate/#{self.class.unique_timestamp}_#{file_suffix}"
    File.open(filename, 'w') do |f|
      f.puts file_template
    end
    puts "created #{filename}"
  end

  private

  def self.unique_timestamp
    t = Time.now
    t += 1 while Dir[File.join('db', 'migrate', "#{t.strftime("%Y%m%d%H%M%S")}*.rb")].present?
    t.strftime("%Y%m%d%H%M%S")
  end

  def self.schema_migration_created?
    Dir[File.join('db', 'migrate', "*create_gatherable_schema.rb")].present?
  end

  def self.schema_migration
    "db/migrate/#{unique_timestamp}_create_gatherable_schema.rb"
  end

  def table_name
    @table_name ||= data_point.classify.table_name
  end

  def file_template
    data_type = data_point.data_type.to_s
    <<-template
class CreateGatherable#{table_name.classify}  < ActiveRecord::Migration
  def up
    create_table 'gatherable.#{table_name}', :primary_key => '#{data_point.name}_id' do |t|
      t.#{data_type} :#{data_point.name}, :null => false
      t.string :#{Gatherable.config.global_identifier}, :index => true
      t.timestamps :null => false
    end
  end

  def down
    drop_table 'gatherable.#{table_name}'
  end
end
    template
  end

  def file_suffix
    @file_suffix ||= "create_gatherable_#{table_name.singularize}.rb"
  end

  def already_found_message
    "migrations #{matching_migrations} already exist. Not creating migration for #{data_point.name}"
  end

  def matching_migrations
    @matches ||= Dir[File.join('db', 'migrate', "*#{file_suffix}")]
  end
end
