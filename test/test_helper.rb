begin
  require 'simplecov'
  SimpleCov.start
rescue Exception
  puts "Install simplecov for test coverage..."
end

PINGER_CONFIG = ENV["PINGER_CONFIG"] = File.expand_path("../.pinger.test.yml", __FILE__)

gem "minitest"
require "minitest/autorun"
require "minitest/should"
require "webmock/minitest"

begin require "turn"; rescue LoadError; end

require "pinger"
Pinger.reset_database!

TEST_URI = "http://example.com"

module MiniTest
  class Unit
    class TestCase    
      
      def setup
        Pinger::Alert.dataset.destroy
        Pinger::Ping.dataset.destroy
        Pinger::URI.dataset.destroy
        stub_request(:get, TEST_URI).to_return(:body => "<h1>Hello Pinger!</h1>", :status => 200)
      end
      
      def clear_pinger_config
        Pinger.instance_variable_set("@config", nil)
        Pinger.instance_variable_set("@config_path", nil)
      end
      
      def reset_pinger_config
        clear_pinger_config
        ENV["PINGER_CONFIG"] = PINGER_CONFIG
      end
      
      def uri
        @uri ||= Pinger::URI.find_or_create(:uri => TEST_URI)
      end

    end
  end
end
