class ControllerWriter
  attr_reader :data_table
  def initialize(data_table)
    @data_table = data_table
  end

  def write
    if File.exists?(filename)
      puts "Controller already defined for #{data_table.name}. Skipping"
      return
    end
    FileUtils.mkdir_p('app/controllers/gatherable')
    File.open(filename, 'w') do |f|
      f.puts controller_contents
    end
    puts "created #{filename}" if File.exists?(filename)
  end

  private

  def filename
    controller_file = "#{data_table.name.to_s.pluralize}_controller.rb"
    File.join(Rails.root, 'app', 'controllers', 'gatherable', controller_file)
  end

  def controller_contents
    <<-controller
module Gatherable
  class #{data_table.controller_name} < Gatherable::ApplicationController
  end
end
    controller
  end
end
