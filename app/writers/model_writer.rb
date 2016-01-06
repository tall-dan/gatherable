class ModelWriter
  attr_reader :data_table
  def initialize(data_table)
    @data_table = data_table
  end

  def write
    if File.exists?(filename)
      puts "model already defined for #{data_table.name}. Skipping"
      return
    end
    FileUtils.mkdir_p('app/models/gatherable')
    File.open(filename, 'w') do |f|
      f.puts model_contents
    end
    puts "created #{filename}" if File.exists?(filename)
  end

  private

  def filename
    model_file = "#{data_table.name}.rb"
    File.join(Rails.root, 'app', 'models', 'gatherable', model_file)
  end

  def model_contents
    <<-model
module Gatherable
  class #{data_table.class_name} < ActiveRecord::Base
    self.table_name = '#{data_table.name.to_s.pluralize}'
    self.table_name_prefix = 'gatherable.'
  end
end
    model
  end
end
