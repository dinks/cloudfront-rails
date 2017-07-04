module Cloudfront
  module Rails
    class Importer
      class ResponseError < StandardError
        attr_reader :response

        def initialize(response)
          @response = response
        end
      end
    end
  end
end
