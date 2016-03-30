source 'https://rubygems.org'
ruby '2.2.4'
gem 'rails', '4.2.5'

# Databases
gem 'mysql2'

group :assets do
  gem 'coffee-rails', '~> 4.1.1'
  gem 'sass-rails', '~> 5.0'
  gem 'compass-rails', '>= 2.0.4'
  gem 'compass-blueprint'

  gem 'therubyracer'
  gem 'libv8'

  gem 'uglifier', '>= 1.0.3'
end

# Views
gem 'jquery-rails'
gem 'haml-rails'
gem 'to-csv', :require => 'to_csv'
gem 'kaminari'
gem 'oai', '~> 0.4.0'
gem 'analytical'

# Admin
gem 'country-select'
gem 'activeadmin', '~> 1.0.0.pre2'

# Authentications
gem 'devise', '~> 3.5.3'
gem 'cancancan', '~> 1.13.1'

# Database improvements
gem 'squeel', '~> 1.2.3'
gem 'nilify_blanks'

# Search
gem 'sunspot_rails', '~> 2.2.3'
gem 'sunspot_solr', '~> 2.2.3'

# Web Server
gem 'unicorn'

gem 'activerecord-session_store'
gem 'protected_attributes'

# Media Detection
gem 'ruby-filemagic'

# Deployment
gem 'capistrano'
gem 'capistrano-ext'
gem 'capistrano-unicorn'

# Logging
gem 'rollbar'
gem 'newrelic_rpm'

# Misc
gem 'progress_bar'
gem 'paper_trail', '~> 4.0.1'
gem 'quiet_assets'
gem 'roo', '~> 2.1.0'
# Unpublished version used for ability to use StringIO. https://github.com/roo-rb/roo-xls/pull/7
gem 'roo-xls', :github => 'roo-rb/roo-xls', :ref => '0a5ef88'
gem 'streamio-ffmpeg'
gem 'rake', '< 11.0'

# Image processing
gem 'rmagick'

# Scheduling
gem 'whenever', :require => false

group :development, :test do
  gem 'turn', '~> 0.8.3', :require => false
  gem 'rspec-rails', '~> 2.0'
  gem 'sextant'
  gem 'thin'

  gem 'spring'
  gem 'spring-commands-rspec'

  gem 'pry'
  gem 'pry-rails'

  gem 'letter_opener'

  # Guard
  gem 'guard', '~> 2.13.0'
  gem 'guard-bundler'
  gem 'guard-rails'
  gem 'guard-rspec'

  gem 'rb-inotify', :require => RUBY_PLATFORM.include?('linux') ? 'rb-inotify' : false
  gem 'rb-fsevent', :require => RUBY_PLATFORM.include?('darwin') ? 'rb-fsevent' : false
end

group :development do
  gem 'annotate'
  gem 'binding_of_caller'
  gem 'better_errors'
  gem 'rubocop'
end

group :test do
  gem 'capybara'
  gem 'poltergeist'
  gem 'factory_girl_rails'
  gem 'database_cleaner'
  gem 'email_spec'
  gem 'launchy'
end
