require "rails"
require "net/http"

require "cloudfront/rails/version"

module Cloudfront
  module Rails
    # Nothing to do
  end
end

require "cloudfront/rails/importer"
require "cloudfront/rails/importer/response_error"
require "cloudfront/rails/railtie"
