source 'http://rubygems.org'

#gem 'bson', '1.3.2'
gem 'rails', '3.2.2'
gem 'jquery-rails'
gem 'rake'
gem 'quality-measure-engine', :git => 'https://github.com/pophealth/quality-measure-engine.git', :branch => 'develop' 
#gem 'quality-measure-engine', '1.1.5'
gem 'health-data-standards', :git => 'https://github.com/projectcypress/health-data-standards.git', :branch => 'develop'
#gem 'health-data-standards', '1.0.1'
#gem 'health-data-standards', path: '../shared/health-data-standards'

gem 'bson', '1.5.1'
gem 'bson_ext', '1.5.1'
gem 'mongoid', '~> 2.0'
gem 'state_machine'


gem 'devise', '~> 2.0'
gem 'simple_form'
gem 'nokogiri', '~> 1.4.4'

gem 'prawn'
gem "prawnto_2", :require => "prawnto"

gem 'pry'
gem 'pry-nav'

gem 'redis', '~> 2.2.2'

# Windows doesn't have syslog, so need a gem to log to EventLog instead
gem 'win32-eventlog', :platforms => [:mswin, :mingw]

group :assets do
  gem 'sass-rails'
  gem 'coffee-rails'
  gem 'uglifier'
end

group :test, :develop do
  gem 'turn', :require => false
  gem 'minitest'
  gem "tailor"
  gem 'simplecov', :require => false
  gem 'mocha', :require => false
end

group :production do
  gem 'therubyracer', :platforms => [:ruby, :jruby]
end

