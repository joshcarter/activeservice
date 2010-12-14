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
      attr_accessor :name_filter, :type, :protocol, :timeout
    end

    def self.browser
      # Lazy create the browser so client has time to initialize 
      # stuff like the type and protocol.
      @@browser ||= Browser.new(type, protocol || 'tcp')
    end
    
    def self.find(conditions)
      raise "find() only supports find(:all)" if (conditions != :all)

      abort_time = Time.now.to_f + (timeout || 1.0)

      loop do
        descriptors = browser.all.values
      
        if name_filter != nil
          descriptors = descriptors.select { |d| d.name.match(name_filter) }
        end

        if descriptors.length > 0
          return descriptors
        else
          # Need to wait until abort_time to see if we get any
          # further browse results.
          return [] if Time.now.to_f > abort_time

          sleep 0.1
        end
      end
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

    def self.with_one(&block)
      descriptors = find(:all)
      instance = nil

      if (descriptors.length == 0)
        raise ActiveService::NoServicesRegistered.new("Expected exactly one service, none are registered")
      end

      begin
        # Choose random service descriptor
        descriptor = descriptors[rand(descriptors.length)]
        
        instance = create_instance(descriptor)
        yield instance
      ensure
        destroy_instance(instance)
      end
    end

    def self.each(&block)
      descriptors = find(:all)

      descriptors.each do |descriptor|
        instance = nil
        
        begin
          instance = create_instance(descriptors.first)
          yield instance
        ensure
          destroy_instance(instance)
        end
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
