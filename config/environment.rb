# Load the rails application
require File.expand_path('../application', __FILE__)

Haml::Template.options[:format] = :html5
Haml::Template.options[:ugly] = true
Encoding.default_external = Encoding::UTF_8 # is this really necessary?
I18n.enforce_available_locales = false

# Initialize the rails application
Elephant::Application.initialize!
