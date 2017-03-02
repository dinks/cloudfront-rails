$LOAD_PATH.unshift File.expand_path('../../lib', __FILE__)

ENV["RAILS_ENV"] ||= 'test'

require "rubygems"

require "action_controller/railtie"
require 'action_view/railtie'
require "rails/test_unit/railtie"

require "cloudfront/rails"

require "rspec/rails"
require "webmock/rspec"

RSpec.configure do |config|
  config.infer_base_class_for_anonymous_controllers = false
end
