class MigrationWriter
  class << self
    def write(data_point)
      if matching_migration.present?
        #warn and get input. Might be something to modularize, like normal file overwriting w/installs. Or does this happen automagically?
      end
      File.open"#{Time.now.strftime("%Y%m%d%H%M%S")}_#{file_suffix(data_point)}" do
        puts file_template(data_point)
      end
    end

    def file_template(data_point)
      table_name = data_point.name
      data_type = data_point.data_type
      <<-template
        class Create#{table_name.pluralize.capitalize}  < ActiveRecord::Migration
          def up
            create_table :#{table_name.pluralize}, :primary_key => #{table_name}_id do |t|
              t.#{data_type} :#{table_name.singularize}, :null => false
              t.timestamps :null => false
            end
          end
          def down
            drop_table :#{table_name.pluralize}
          end
        end
      template
    end

    def file_suffix(data_point)
      @file_suffix ||= "create_#{data_point.name}.rb"
    end

    def matching_migration
      [] #TODO
    end
  end
end
