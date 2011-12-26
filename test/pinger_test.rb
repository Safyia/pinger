require "test_helper"

class PingerTest < MiniTest::Unit::TestCase

  should "establish database connection" do        
    assert !Pinger.connection.nil?
  end
  
  should "alias connection to Pinger.db" do  
    assert_equal Pinger.connection, Pinger.db
  end
  
  should "create schema on init" do
    assert Pinger.db.table_exists?(:uris)
    assert Pinger.db.table_exists?(:pings)
  end
  
end
