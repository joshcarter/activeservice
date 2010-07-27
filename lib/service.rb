require 'rubygems'
require 'dnssd'
require 'zmq'
require File.join(File.dirname(__FILE__), 'service_info')
require File.join(File.dirname(__FILE__), 'resource_compiler')

require_resource File.join(File.dirname(__FILE__), 'protos', 'rpc')

Thread.abort_on_exception = true

class ThreadStopRequest < RuntimeError
end

module Service
  attr_reader :info

  # Create (and start) new server based on klass.
  def self.new(klass, service_name, service_port = nil)
    object = klass.new
    object.extend Service
    object.instance_variable_set(:@thread, nil)
    object.run(service_name, service_port)
    return object
  end

  def run(service_name, service_port)
    raise "Object is already a DNS-SD service" if @thread

    # Convert ancestor chain from CamelStyle to underscore_style
    type = self.class.to_s.gsub(/\B[A-Z]/, '_\&').downcase

    # Convert ancestor chain from module style to DNS-SD service type
    # i.e., foo::bar::baz becomes _baz._bar._foo
    type = type.split('::').reverse.join('_')

    # TODO: guarantee port cannot conflict
    service_port = ((service_name + type).hash % 10000) + 10000

    @info = ServiceInfo.new(
      :type => type,
      :name => service_name,
      :port => service_port)

    # Set up pipe for sending thread stop event
    @stop_request_read, @stop_request_write = IO.pipe

    @thread = Thread.new do
      self.main
    end
  end

  def stop
    @stop_request_write.write "stop, please"
    @stop_request_write.close

    join
  end

  def join
    raise "Cannot join, not running" unless @thread

    @thread.join
  end

  protected ########################################

  def register_service
    # Per book, should always have a text record, minimally with 
    # txtvers set to 1.
    text_record = DNSSD::TextRecord.new
    text_record['txtvers'] = 1

    # puts "Starting DNS-SD registration"
    DNSSD.register!(@info.name, @info.dnssd_type, 'local.', @info.port, text_record)
    # puts "Registered"
  end

  def start_rpc_listener
    ctx = ZMQ::Context.new(1)
    @rpc_listener = ctx.socket(ZMQ::REP);
    @rpc_listener.bind(@info.zmq_address)
  end

  def dispatch_rpc(bytes)
    rpc = Rpcmsg::Header.new
    rpc.parse_from_string(bytes)

    # Subclass needs to provide actual method implementation, resource
    # compiler will have stubbed it with something that raises NYI.
    result = self.send(rpc.method.to_sym, rpc.parameter)

    # TODO: encode and send back result
  end

  def main
    # puts "Dispatcher thread running"
    
    start_rpc_listener
    register_service

    begin
      loop do
        #
        # TODO: can't do one select that covers both the stop request pipe
        # and the ZMQ listener, so I need to wait on the ZMQ for 1 second,
        # check the stop request, then go back to ZMQ. Fix me (somehow).
        #
        pending = select([@stop_request_read], [], [], 0)

        if pending
          pending.first.each do |io|
            if (io == @stop_request_read)
              io.read; io.close
              raise ThreadStopRequest
            else
              raise "Unexpected IO source #{io}"
            end
          end
        end

        pending = ZMQ::select([@rpc_listener], [], [], 1)

        if pending
          pending.first.each do |io|
            if (io == @rpc_listener)
              dispatch_rpc(io.recv)
            else
              raise "Unexpected IO source #{io}"
            end
          end
        end
      end
    rescue ThreadStopRequest => e
      # Just fall through
    end
    
    # puts "Dispatcher thread stopping"
  end
end
