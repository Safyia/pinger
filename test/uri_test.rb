require "test_helper"

class URITest < MiniTest::Unit::TestCase

  def setup
    Pinger::URI.dataset.destroy
  end

  should "be a sequel model" do        
    assert Pinger::URI.ancestors.include?(Sequel::Model)
  end
  
  should "have table present in database" do        
    assert Pinger.db.table_exists?(:uris)
  end
  
  should "have proper attributes" do
    assert_equal [ :id, :uri, :created_at ], Pinger::URI.columns
  end
  
  should "save uri to database" do
    uri = Pinger::URI.new(:uri => "http://example.com")
    assert uri.save
    assert !uri.created_at.nil?
  end
  
  context "An existing uri" do
    
    def setup
      Pinger::URI.dataset.destroy
      @uri = Pinger::URI.find_or_create(:uri => "http://example.com")
    end
    
    should "request and create ping" do
      @uri.request!
      assert_equal 1, Pinger::Ping.count
    end
    
    should "be deleted" do
      count = Pinger::URI.count
      @uri.destroy
      assert_equal count - 1, Pinger::URI.count
    end
    
  end
  
end
