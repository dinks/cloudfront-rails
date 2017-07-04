module Cloudfront
  module Rails
    class Importer
      include HTTParty

      base_uri "https://ip-ranges.amazonaws.com"
      follow_redirects true
      default_options.update(verify: true)

      class ResponseError < HTTParty::ResponseError; end

      class << self
        def fetch
          resp = get "/ip-ranges.json", timeout: ::Rails.application.config.cloudfront.timeout

          if resp.success?
            json = ActiveSupport::JSON.decode resp

            trusted_ipv4_proxies = json["prefixes"].map do |details|
                                     IPAddr.new(details["ip_prefix"])
                                   end

            trusted_ipv6_proxies = json["ipv6_prefixes"].map do |details|
                                     IPAddr.new(details["ipv6_prefix"])
                                   end

            trusted_ipv4_proxies + trusted_ipv6_proxies
          else
            raise ResponseError.new(resp.response)
          end
        end

        def fetch_with_cache
          ::Rails.cache.fetch("cloudfront-rails-ips",
                              expires_in: ::Rails.application.config.cloudfront.expires_in) do
            self.fetch
          end
        end
      end
    end
  end
end
