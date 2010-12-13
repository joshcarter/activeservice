require 'rubygems'
require 'mocha'
require 'test/unit'

Thread::abort_on_exception = true

# Class which registers a DNS-SD service provider.
#
class TestProvider
  NAME = 'Test Provider'
  TYPE = 'test_provider'

  def initialize(params)
    @name = params[:name]
    @type = params[:type]
    @port = params[:port] || 10081
    @protocol = params[:protocol] || 'tcp'
    @domain = params[:domain] || 'local.'

    @incoming = Queue.new
    @outgoing = Queue.new
    @thread = Thread.new { run }
  end
  
  def run
    DNSSD.register!(@name, "_#{@type}._#{@protocol}", @domain, @port)

    loop do
      r = @incoming.pop
      return if r == :stop
      @outgoing.push r
    end
  end

  def stop
    @incoming.push :stop
  end

  def wait_for_register
    @incoming.push :just_checking
    @outgoing.pop
  end
end
