require 'rubygems'
require 'socket'
require 'dnssd'

module ActiveService
  class Descriptor
    attr_reader :name, :port, :host, :protocol

    def initialize(params)
      @name = params[:name] || nil
      @type = params[:type] || nil
      @protocol = params[:protocol] || 'tcp'
      @host = params[:host] || Socket.gethostname + ".local."
      @port = params[:port] || nil
      @address = params[:address] || nil
    end

    def address
      # Auto-resolve address if needed
      if @address.nil?
        raise("Cannot resolve address without host") if @host.nil?

        info = Socket.getaddrinfo(@host, 0, Socket::AF_UNSPEC, Socket::SOCK_STREAM)

        raise "Cannot resolve name #{@host}" unless (info && info[0])
        @address = info[0][3]
      end

      @address
    end

    def type
      "_#{@type}._#{@protocol}"
    end
  end
end
