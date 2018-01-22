require "httparty"

module Cloudfront
  module Rails
    class Railtie < ::Rails::Railtie

      module CheckTrustedProxies
        def trusted_proxy?(ip)
          ::Rails.application.config.cloudfront.ips.any?{ |proxy| proxy === ip } || super
        end
      end

      Rack::Request::Helpers.prepend CheckTrustedProxies

      module RemoteIpProxies
        def proxies
          super + ::Rails.application.config.cloudfront.ips
        end
      end

      ActionDispatch::RemoteIp.prepend RemoteIpProxies

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
              json = ActiveSupport::JSON.decode resp.body

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

      CLOUDFRONT_DEFAULTS = {
        expires_in: 12.hours,
        timeout: 5.seconds,
        ips: Array.new
      }

      config.before_configuration do |app|
        app.config.cloudfront = ActiveSupport::OrderedOptions.new
        app.config.cloudfront.reverse_merge! CLOUDFRONT_DEFAULTS
      end

      config.after_initialize do |app|
        begin
          ::Rails.application.config.cloudfront.ips += Importer.fetch_with_cache
        rescue Importer::ResponseError => e
          ::Rails.logger.error "Cloudfront::Rails: Couldn't import from Cloudfront: #{e.response}"
        rescue => e
          ::Rails.logger.error "Cloudfront::Rails: Got exception: #{e}"
        end
      end

    end
  end
end
