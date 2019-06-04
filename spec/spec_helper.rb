# $LOAD_PATH.unshift File.expand_path('../../../discourse_api/lib', __FILE__)
# require File.expand_path('../../../discourse_api/lib/discourse_api', __FILE__)
require 'simplecov'

SimpleCov.formatter = SimpleCov::Formatter::MultiFormatter.new([SimpleCov::Formatter::HTMLFormatter])

SimpleCov.start do
  add_filter "/spec/"
end

require 'momentum_api'
require 'rspec'
require 'json'
require 'webmock/rspec'


def fixture_path
  File.expand_path("../fixtures", __FILE__)
end

def fixture(file)
  File.new(fixture_path + '/' + file)
end

def json_fixture(json_file)
  json_object = File.read(fixture_path + '/' + json_file)
  JSON.parse(json_object)
end
