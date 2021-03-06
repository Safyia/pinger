module Pinger
  class URI < Sequel::Model

    ValidIpAddressRegex = Regexp.new("^(([0-9]|[1-9][0-9]|1[0-9]{2}|2[0-4][0-9]|25[0-5])\.){3}([0-9]|[1-9][0-9]|1[0-9]{2}|2[0-4][0-9]|25[0-5])$");
    ValidHostnameRegex  = Regexp.new("^(([a-zA-Z]|[a-zA-Z][a-zA-Z0-9\-]*[a-zA-Z0-9])\.)*([A-Za-z]|[A-Za-z][A-Za-z0-9\-]*[A-Za-z0-9])$");
    
    one_to_many :pings
    many_to_many :alerts, :join_table => :pings, :right_key => :id, :right_primary_key => :ping_id
    
    plugin :association_dependencies, :pings => :destroy
    plugin :timestamps
  
    def self.standardize(uri)
      uri = "http://#{uri}" unless uri.to_s.strip.match(/^https?:\/\//)
      uri
    end

    def before_validation
      self.uri = Pinger::URI.standardize(uri)
      parse
      super
    end
    
    def validate
      super
      self.errors.add(:uri, "is invalid") unless self.host =~ ValidIpAddressRegex || self.host =~ ValidHostnameRegex
    end
    
    def created_at
      t = values[:created_at]
      FormattedTime.at(t) unless t.nil?
    end
        
    def ping!
      ping = Pinger::Ping.create(:uri => self)
      ping.request!
      ping
    end

    def raise_on_failure?(opts={})
      false
    end
    
    def to_param
      id
    end
    
    def average_response_time
      Pinger::Ping.average_response_time(self)
    end
    
    def average_response_size
      Pinger::Ping.average_response_size(self)
    end
    
    def average_response_size_kb
      (average_response_size / 1024.0).round(3)
    end
    
    private
    
      def parse
        begin
          parsed = ::URI.parse(self.uri)
          [ :scheme, :userinfo, :host, :port, :registry, :path, :opaque, :query, :fragment, :request_uri ].each do |part|
            self.values[part] = parsed.send(part)
          end
        rescue ::URI::InvalidURIError
          self.errors.add(:uri, "is invalid")
        end        
      end
    
  end
end
