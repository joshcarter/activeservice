require File::join(File::dirname(__FILE__), 'active_service', 'browser')
require File::join(File::dirname(__FILE__), 'active_service', 'descriptor')

module ActiveService
  VERSION = "1.0.0"
  
  # Exception classes
  class NoServicesRegistered < RuntimeError; end
  class MoreServicesRegistered < RuntimeError; end

  class Base
    @@browser = nil
    
    class << self
      attr_accessor :name_filter, :type, :protocol
    end

    def self.browser
      # Lazy create the browser so client has time to initialize 
      # stuff like the type and protocol.
      @@browser ||= Browser.new(type, protocol || 'tcp')
      @@browser
    end
    
    def self.find(conditions)
      raise "find() only supports find(:all)" if (conditions != :all)
      
      descriptors = browser.all
      
      if name_filter != nil
        descriptors = descriptors.select { |d| d.name.match(name_filter) }
      end
      
      descriptors
    end

    def self.with_exactly_one(&block)
      descriptors = find(:all)
      instance = nil

      if (descriptors.length == 0)
        raise ActiveService::NoServicesRegistered.new("Expected exactly one service, none are registered")
      elsif (descriptors.length > 1)
        raise ActiveService::MoreServicesRegistered.new("Expected exactly one service, #{descriptors.length} are registered")
      end

      begin
        instance = create_instance(descriptors.first)
        yield instance
      ensure
        destroy_instance(instance)
      end
    end
    
    # Subclasses must override this to create their service instance
    # matching the discovered network info.
    def self.create_instance(descriptor)
      raise "Subclasses must override create_instance"
    end
    
    def self.destroy_instance(instance)
      # Do nothing by default, let Ruby GC take care of it
    end
  end
end
