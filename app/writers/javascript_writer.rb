class JavascriptWriter
  attr_reader :data_table

  def initialize(data_table)
    @data_table = data_table
  end

  def write
    FileUtils.mkdir_p('app/assets/javascripts/gatherable')
    if File.exists?(javascript_class)
      puts "Found #{javascript_class}. Skipping"
      return
    end
    File.open(javascript_class, 'w') do |f|
      f.puts <<-class
var #{data_table.class_name} = {
  create: function(global_identifier, options){
    $.ajax({
      url: '/gatherable/' + global_identifier + '/#{data_table.name.to_s.pluralize}',
      method: 'POST',
      data: { #{data_table.name}: options }
    });
  },
  get: function(global_identifier, id) {
    $.ajax({
      url: '/gatherable/' + global_identifier + '/#{data_table.name}/' + options[#{data_table.name}_id],
    });
  }
}
      class
    end
    puts "created #{javascript_class}" if File.exists?(javascript_class)
  end

  private

  def javascript_class
    javascript_file = "#{data_table.name.to_s.pluralize}.js"
    File.join(Rails.root, 'app', 'assets', 'javascripts', 'gatherable', javascript_file)
  end
end
