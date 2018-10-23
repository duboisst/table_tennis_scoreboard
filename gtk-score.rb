require 'gtk3'
require 'fileutils'

puts "HELLO"

# Require all ruby files in the application folder recursively
application_root_path = File.expand_path(__dir__)
Dir[File.join(application_root_path, '**', '*.rb')].each { |file| 
  require file unless file == File.expand_path(__FILE__)
}

# Define the source & target files of the glib-compile-resources command
resource_xml = File.join(application_root_path, 'resources', 'gresources.xml')
resource_bin = File.join(application_root_path, 'gresource.bin')

# Build the binary
system("glib-compile-resources",
       "--target", resource_bin,
       "--sourcedir", File.dirname(resource_xml),
       resource_xml)

resource = Gio::Resource.load(resource_bin)
Gio::Resources.register(resource)

at_exit do
  # Before existing, please remove the binary we produced, thanks.
  FileUtils.rm_f(resource_bin)
end

app = Score::Application.new
puts app.run