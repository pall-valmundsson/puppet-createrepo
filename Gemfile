source 'https://rubygems.org'

group :development, :test do
  gem 'rake',                    :require => false
  gem "rspec-puppet",            :require => false
  gem 'puppetlabs_spec_helper',  :require => false
  gem 'puppet-lint',             :require => false
  gem 'metadata-json-lint',      :require => false
  gem 'puppet-blacksmith',       :require => false
end

group :system_tests do
  gem 'beaker',                  :require => false
  gem 'beaker-rspec',            :require => false
  gem 'serverspec',              :require => false
end

if puppetversion = ENV['PUPPET_GEM_VERSION']
  gem 'puppet', puppetversion, :require => false
else
  gem 'puppet', :require => false
end
