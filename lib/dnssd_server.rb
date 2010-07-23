require 'rubygems'
require 'dnssd'
require 'service_info'

Thread.abort_on_exception = true

module DnssdService
  def initialize
    # Convert ancestor chain from CamelStyle to underscore_style
    type = self.class.to_s.gsub(/\B[A-Z]/, '_\&').downcase

    # Convert ancestor chain from module style to DNS-SD service type
    # i.e., foo::bar::baz becomes _baz._bar._foo
    type = type.split('::').reverse.join('_')

    @service = ServiceInfo.new(:type => type)
  end

  def run(name)
    @service.name = name
    @service.port = (type.hash % 10000) + 10000 # TODO: ensure port cannot conflict

    # Per book, should always have a text record, minimally with 
    # txtvers set to 1.
    text_record = DNSSD::TextRecord.new
    text_record['txtvers'] = 1

    # puts "Starting queue registration"
    DNSSD.register!(@service.name, @service.dnssd_type, 'local.', @service.port, text_record)
    # puts "Registered"

    @running = true
    @thread = Thread.new do
      self.dispatcher
    end
  end

  def dispatcher
    puts "Dispatcher thread running"

    sleep(2)

    puts "Dispatcher thread stopping"
    @running = false
  end
end

