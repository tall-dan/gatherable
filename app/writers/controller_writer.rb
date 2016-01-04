class ControllerWriter
  attr_reader :data_point
  def initialize(data_point)
    @data_point = data_point
  end

  def write
    if File.exists?(filename)
      puts "Controller already defined for #{data_point.name}. Skipping"
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
    controller_file = "#{data_point.name.to_s.pluralize}_controller.rb"
    File.join(Rails.root, 'app', 'controllers', 'gatherable', controller_file)
  end

  def controller_contents
    <<-controller
module Gatherable
  class #{data_point.controller_name} < Gatherable::ApplicationController
  end
end
    controller
  end
end
