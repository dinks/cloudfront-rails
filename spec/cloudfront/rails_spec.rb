require "spec_helper"

describe Cloudfront::Rails do
  it "has a version number" do
    expect(Cloudfront::Rails::VERSION).not_to be nil
  end

  describe "Railtie" do
    let(:rails_app) do
      Class.new(::Rails::Application) do
        config.active_support.deprecation = :stderr
        config.eager_load = false
        config.cache_store = :null_store
        config.secret_token = SecureRandom.hex
        config.secret_key_base = SecureRandom.hex
      end
    end

    let(:cloudfront_ip1) { "13.124.199.0/24" }
    let(:cloudfront_ip2) { "2600:9000::/28" }
    let(:cloudfront_ips) { [cloudfront_ip1, cloudfront_ip2] }

    let(:ip_ranges) do
      <<EOF
{

  "syncToken": "1488396130",
  "createDate": "2017-03-01-19-22-10",
  "prefixes": [
    {
        "ip_prefix": "13.32.0.0/15",
        "region": "GLOBAL",
        "service": "AMAZON"
    },
    {
        "ip_prefix": "13.54.0.0/15",
        "region": "ap-southeast-2",
        "service": "AMAZON"
    },
    {
        "ip_prefix": "#{cloudfront_ip1}",
        "region": "ap-southeast-2",
        "service": "CLOUDFRONT"
    }
  ],
  "ipv6_prefixes": [
    {
        "ipv6_prefix": "2400:6500:0:7000::/56",
        "region": "ap-southeast-1",
        "service": "AMAZON"
    },
    {
        "ipv6_prefix": "2400:6500:0:7100::/56",
        "region": "ap-northeast-1",
        "service": "AMAZON"
    },
    {
        "ipv6_prefix": "#{cloudfront_ip2}",
        "region": "GLOBAL",
        "service": "CLOUDFRONT"
    }
  ]
}
EOF
    end

    let(:status) { 200 }

    before(:each) do
      rails_app.config.cloudfront.ips = Array.new

      stub_request(:get, "https://ip-ranges.amazonaws.com/ip-ranges.json").
        to_return(status: status, body: ip_ranges)
    end

    after(:each) do
      Rails.cache.clear
    end

    it "works with valid responses" do
      expect_any_instance_of(Logger).to_not receive(:error)

      expect { rails_app.initialize! }.to_not raise_error

      expect(rails_app.config.cloudfront.ips).to eq(cloudfront_ips)
    end

    describe "with unsuccessful responses" do
      let(:status) { 404 }

      it "doesn't prevent rails startup" do
        expect_any_instance_of(Logger).to receive(:error).once.and_call_original
        expect{rails_app.initialize!}.to_not raise_error
        expect(rails_app.config.cloudfront.ips).to be_blank
      end
    end

    describe "with invalid bodies" do
      let(:ip_ranges) { "asdfasdfasdfasdfasdf" }

      it "doesn't prevent rails startup" do
        expect_any_instance_of(Logger).to receive(:error).once.and_call_original
        expect{rails_app.initialize!}.to_not raise_error
        expect(rails_app.config.cloudfront.ips).to be_blank
      end
    end
  end
end
