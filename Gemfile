# encoding: UTF-8
# -*- mode: ruby -*-
# vi: set ft=ruby :

# let's be bleeding and not specify andy versions until v1.0.0

source 'https://rubygems.org'

chef_version = ENV.key?('CHEF_VERSION') ? ENV['CHEF_VERSION'] : nil

group :development do
  gem 'rake'
  gem 'rb-fsevent'
  gem 'berkshelf'
  gem 'chef', chef_version unless chef_version.nil? # Ruby 1.9.3 support
end

group :test do
  gem 'chefspec'
  gem 'rspec'
  gem 'codeclimate-test-reporter', group: :test, require: nil
end

group :lint do
  gem 'foodcritic'
  gem 'rubocop'
end

group :kitchen_common do
  gem 'test-kitchen'
end

group :kitchen_docker do
  gem 'kitchen-docker'
end

group :kitchen_vagrant do
  gem 'kitchen-vagrant'
end

group :kitchen_cloud do
  gem 'kitchen-digitalocean'
  gem 'kitchen-ec2'
end

group :guard do
  gem 'guard'
  # use below for gems like guard-foodcritic which
  # don't yet support guard 3 :(
  # gem 'guard', '= 2.8.2'
  gem 'guard-foodcritic'
  gem 'guard-kitchen'
  gem 'guard-rspec'
  gem 'guard-rubocop'
end

group :integration do
  gem 'vagrant-wrapper'
end

group :integration, :integration_cloud do
  gem 'serverspec'
end
