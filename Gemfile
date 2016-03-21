source 'http://rubygems.org'

gem 'rails', '3.1.12'

# Gems used only for assets and not required
# in production environments by default.
group :assets do
  #gem 'sass-rails', "  ~> 3.1.0"
  gem 'sass-rails' #, '3.1.4' # ugly bug introduced by 3.1.5
  gem 'coffee-rails' #, "~> 3.1.0"
  gem 'uglifier'
end

# Gem for precompiling assets
group :production do
  gem 'therubyracer'
end

# gem 'rake', '10.1.1'

# Bundle edge Rails instead:
# gem 'rails', :git => 'git://github.com/rails/rails.git'

gem 'unicorn', '4.6.2'

gem 'dynamic_form'

gem 'pg'

gem 'haml'
gem 'haml-rails'

gem 'acts_as_list'

gem 'jquery-rails', '1.0.19'

gem 'kaminari' #, '0.10.4'

gem 'koelner_phonetic_encoder'

gem 'prawn', '~> 1.3.0'
gem 'prawn-table', '~> 0.2.1'
#gem 'prawn-layout', :require => 'prawn/format'

gem 'RubyInline'
gem 'image_science' #, :git => 'http://github.com/asynchrony/image_science.git'

# gem 'carrierwave', '0.5.7'

gem 'mysql2', '~> 0.3.17'
gem 'thinking-sphinx', '~> 3.1.3'

# Deploy with Capistrano
# gem 'capistrano'

# To use debugger (ruby-debug for Ruby 1.8.7+, ruby-debug19 for Ruby 1.9.2+)
# gem 'ruby-debug'
# gem 'ruby-debug19'

# Bundle the extra gems:
# gem 'bj'
# gem 'nokogiri'
# gem 'sqlite3-ruby', :require => 'sqlite3'
# gem 'aws-s3', :require => 'aws/s3'

# Bundle gems for the local environment. Make sure to
# put test-only gems in this group so their generators
# and rake tasks are available in development mode:
group :test do
  gem 'shoulda'
  gem 'factory_girl_rails'
end

gem 'text_hyphen_rails', :github => 'tnt/text-hyphen-rails', :branch => 'master' # path: '../../../git/text_hyphen_rails'
