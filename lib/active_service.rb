require File::join(File::dirname(__FILE__), 'active_service', 'browser')
require File::join(File::dirname(__FILE__), 'active_service', 'descriptor')

module ActiveService
  VERSION = "1.0.0"
  
  # Exception classes
  class NoServicesRegistered < RuntimeError; end
  class MoreServicesRegistered < RuntimeError; end

  class Base
    def self.exactly_one
      instances = find(:all)

      if (instances.length == 0)
        raise ActiveService::NoServicesRegistered.new("Expected exactly one service, none are registered")
      elsif (instances.length > 1)
        raise ActiveService::MoreServicesRegistered.new("Expected exactly one service, #{instances.length} are registered")
      else
        instances.first
      end
    end
    
  end
end