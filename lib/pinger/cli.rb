require 'pinger'

module Pinger

  module CLI
  
    UTILITY_COMMANDS = %w(list stats batch help)
    URI_COMMANDS     = %w(add rm show ping) 
    COMMANDS         = UTILITY_COMMANDS + URI_COMMANDS
 
    def self.run(command, args)
      if URI_COMMANDS.include?(command)
        if args.length == 1
          uri = Pinger::URI.standardize(args.first)
          result = Commands.send(command, uri)
        else
          result = usage(command)
        end
      else
        command = :help unless COMMANDS.include?(command) && args.length == 0
        result = Commands.send(command)
      end
      result
    end

    def self.usage(command)
      "Usage: pinger #{command} URI"
    end
       
    module Commands
          
      extend self
      
      def list
        uris = Pinger::URI.order(:uri)
        return "No uris have been added to pinger. Add a uri with `pinger add URI`" if uris.empty?
        uris.map(:uri).join("\n")
      end
      
      def stats
        "#{Pinger::Ping.count} pings on #{Pinger::URI.count} uris"     
      end

      def batch
        @batch = Batch.new
        @batch.process
        "#{@batch.uris.length} pings complete"
      end
      
      def add(uri=nil)
        return "#{uri} already exists in pinger" if find_uri(uri) 
        record = Pinger::URI.new(:uri => uri)
        if record.save
          "#{uri} was successfully added to pinger"
        else
          "#{uri} could not be added to pinger"
        end 
      end
      
      def rm(uri=nil)
        if record = Pinger::URI.find(:uri => uri)
          if record.destroy
            "#{uri} was successfully removed from pinger"
          else
            "#{uri} could not be removed from pinger"
          end
        else     
          "#{uri} doesn't exist in pinger"
        end

      end
      
      def ping(uri=nil)
        record = find_uri(uri)
        return uri_not_found(uri) if record.nil?
        #puts "#{FormattedTime.now.formatted} - pinging #{uri}"
        ping = Pinger::Ping.create(:uri => record)
        ping.request!
        "#{FormattedTime.now.formatted} - finished in #{ping.response_time} seconds with status #{ping.status}"
      end
      
      def show(uri=nil)
	      record = find_uri(uri)
        return uri_not_found(uri) if record.nil?
        out = <<OUT
#{uri}
#{'=' * (uri.length + 3)}
#{record.pings.count} pings since #{record.created_at.formatted}
#{'-' * 40}
OUT
        out << record.pings.reverse.map{ |ping|
          [ ping.created_at.formatted, ping.status, "#{ping.response_time}s"  ].join(", ")
        }.join("\n")
        out
      end
 
      def self.help
        out = <<HELP
Welcome to pinger! Here's the rundown:

  pinger help       # Shows pinger's usage
  pinger stats      # Shows stats for pings and uris

  pinger list       # Lists all uris in pinger's database
  pinger add URI    # Add a uri to pinger's database
  pinger remove URI # Remove the uri from pinger's database
  pinger ping URI   # Test the uri
  pinger show URI   # Show details for a uri

HELP
      end
      
      private

        def find_uri(uri)
          uri = Pinger::URI.standardize(uri)
          Pinger::URI.find(:uri => uri)         
        end
        
        def uri_not_found(uri)
         "#{uri} hasn't been added to pinger. Add it with `pinger add #{uri}`"
        end

    end
    
  end

end
