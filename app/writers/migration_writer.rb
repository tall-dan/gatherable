class MigrationWriter
  attr_reader :data_table

  def initialize(data_table)
    @data_table = data_table
  end

  def self.write_schema_migration
    FileUtils.mkdir_p('db/migrate')
    return if schema_migration_created?
    File.open(schema_migration, 'w') do |f|
      f.puts <<-schema_migration
class CreateGatherableSchema < ActiveRecord::Migration
  def up
    create_schema '#{Gatherable.config.schema_name}'
  end

  def down
    drop_schema '#{Gatherable.config.schema_name}'
  end
end
      schema_migration
    end
    puts "created #{schema_migration}" if File.exists?(schema_migration)
  end

  def write
    if matching_migrations.present?
      puts already_found_message
      return
    end
    FileUtils.mkdir_p('db/migrate')
    filename = "db/migrate/#{self.class.unique_timestamp}_#{file_suffix}"
    File.open(filename, 'w') do |f|
      f.puts file_template
    end
    puts "created #{filename}" if File.exists?(filename)
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
    @table_name ||= data_table.classify.table_name
  end

  def file_template
    <<-template
class CreateGatherable#{data_table.name.to_s.classify} < ActiveRecord::Migration
  def up
    create_table '#{table_name}', :primary_key => '#{data_table.name}_id' do |t|
      #{migration_columns}
      t.string :#{Gatherable.config.global_identifier}, :index => true
      t.timestamps :null => false
    end
  end

  def down
    drop_table '#{table_name}'
  end
end
    template
  end

  def migration_columns
    data_table.columns.inject("") do |columns, (name, type)|
      non_null = ", :null => false" if name == data_table.name
      columns << "t.#{type} :#{name}#{non_null}\n"
    end
  end

  def file_suffix
    @file_suffix ||= "create_gatherable_#{data_table.name}.rb"
  end

  def already_found_message
    "migrations #{matching_migrations} already exist. Skipping migration for #{data_table.name}"
  end

  def matching_migrations
    @matches ||= Dir[File.join('db', 'migrate', "*#{file_suffix}")]
  end
end
