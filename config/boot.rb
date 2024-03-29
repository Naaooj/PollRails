require 'rubygems'

# Set up gems listed in the Gemfile.
ENV['BUNDLE_GEMFILE'] ||= File.expand_path('../../Gemfile', __FILE__)

require 'bundler/setup' if File.exists?(ENV['BUNDLE_GEMFILE'])

# Bundler 1.0.10 loads Psych as a YAML engine by default. 
# Psych does not work fine with rails 3.0.3 qnd greater
require 'yaml'
YAML::ENGINE.yamler= 'syck'