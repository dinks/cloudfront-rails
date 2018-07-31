module Cloudfront
  module Rails
    class Importer
      class << self
        def fetch
          uri = URI("https://ip-ranges.amazonaws.com/ip-ranges.json")
           response = Net::HTTP.start(uri.host,
                                     uri.port,
                                     use_ssl: uri.scheme == 'https',
                                     open_timeout: ::Rails.application.config.cloudfront.timeout,
                                     read_timeout: ::Rails.application.config.cloudfront.timeout,
                                     ssl_timeout:  ::Rails.application.config.cloudfront.timeout
                                    ) do |http|
            http.request(Net::HTTP::Get.new(uri))
          end

          case response
          when Net::HTTPSuccess
            json = ActiveSupport::JSON.decode response.body

            trusted_ipv4_proxies = json["prefixes"].select do |details|
              details["service"] == 'CLOUDFRONT'
            end.map do |details|
              IPAddr.new(details["ip_prefix"])
            end

            trusted_ipv6_proxies = json["ipv6_prefixes"].select do |details|
              details["service"] == 'CLOUDFRONT'
            end.map do |details|
              IPAddr.new(details["ipv6_prefix"])
            end

            trusted_ipv4_proxies + trusted_ipv6_proxies
          else
            raise ResponseError.new(response)
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
