ActiveService
=============

ActiveService is a lightweight framework built on [DNS Service
Discovery][1], a/k/a the top level of Zeroconf/Bonjour. It allows you
to easily define clients to network services, allowing your
application to skip all the host/port configuration gunk, and instead
pick network services dynamically.

[1]: http://www.dns-sd.org/

Background
----------

Many applications (particularly in server environments) use static configurations, either coming from config files or -- let's be honest -- hard coded in the application:

    Redis.new(:host => "redis.acme.com", :port => 6389)

However, what your code *really* cares about is not so much the host, but rather the service you're trying to access. Just as DNS solves the problem of mapping a descriptive host name to an IP address, DNS-SD (service discovery) solves the problem of mapping a descriptive service name and type to a host name and port. DNS-SD is more fully described in the book [Zero Configuration Networking: The Definitive Guide][2].

In the example above, you could use a DNS-SD publisher like Avahi to advertise the services it provides. (See sample config file below.) The DNS-SD gem allows you to browse and select services; the role of ActiveService is to do the common legwork for you. You just need to create a class that represents the service you want to access, for example:

    # Service wrapper for Redis. Assumes master Redis server(s) adversise
    # themselves with a DNS-SD type of "_redis._tcp".
    class RedisService < ActiveService::Base
      self.type = "redis"
      self.protocol = "tcp"

      # Service must provide this to create the appropriate service objects,
      # one for each service currently in DNS-SD matching the type/name/etc.
      # specification. This is called every time find(), all(), with_*() are
      # used to access the services.
      def self.create_instance(descriptor)
        Redis.new(:host => descriptor.host, :port => descriptor.port)
      end
  
      # Service may optionally provide this method if there's any cleanup
      # needed for the instances created in create_instance.
      def self.destroy_instance(instance)
        # Nothing needed, Redis objects clean up on their own
      end
    end

Key things to note: in this example the service type is "redis" and you use it by creating a Redis object. You could then use this class in your application like so:

    RedisService.with_one do |redis|
      redis['foo'] = 'bar'
    end

Before the block executes, DNS-SD is consulted to find all services of the correct type, and (in this case) a random one is chosen. Within the context of the block, the Redis client object is ready for use. Next time you need to access the service, consult your service class again. Service browsing and resolution run in a separate thread, so your application's code is always using cached values.

Selecting Services by Name
--------------------------

In a user-facing application, the common use case is DNS-SD would select all services matching a given type, then let the user select the desired *instance* of the service by a human-readable name. In a server environment, you (probably) want your application to automatically select the right service.

Using Multiple Service Instances
--------------------------------

TODO: more here

    # Pick a service instance, any will do.
    RedisService.with_one do |redis|
      redis['foo'] = 'bar'
      redis['bar'] = 'baz'
    end

    # Expect *exactly* one service on the network; for example in
    # master/slave configurations only the master should be publishing
    # a service record.
    RedisService.with_exactly_one do |redis|
      redis['foo'] = 'bar'
    end

    # Do something with each service on the network. (Don't try to use
    # this for poor-man's high availability, unless you really know what
    # you're doing.)
    RedisService.each do |redis|
      redis['foo'] = 'bar'
    end


Late Binding
------------

TODO: more here


Multiple Client Objects for a Service
-------------------------------------

Some services represent many client objects, for example accessing a
CIM object manager could create a whole pile of CIM instances. In this
situation, it would make sense to do something more like the following:

    class NetworkPort < ActiveCim::Base
      self.cim_class_name = "CIM_NetworkPort"
    end

    class CimService < ActiveService::Base
      self.type = 'cimxml'

      def self.create_instance(descriptor)
        # Simply return the service descriptor itself.
        descriptor
      end

      def self.network_ports
        CimService.with_exactly_one do |descriptor|
          site = "http://#{descriptor.host}:#{descriptor.port}/root/cimv2"
          NetworkPort.find(:all, :site => site)
        end
      end
    end

    CimService.network_ports.each do |port|
      puts port.name
    end

Sample Avahi Configuration
--------------------------

Sample Avahi configuration file for Redis service on Linux/BSD:

    # File: /etc/avahi/services/redis.service

    <?xml version="1.0" standalone='no'?>
    <!DOCTYPE service-group SYSTEM "avahi-service.dtd">

    <service-group>
      <name replace-wildcards="yes">%h Redis Server</name>
      <service>
        <type>_redis._tcp</type>
        <port>6379</port>
      </service>
    </service-group>

License
-------

Copyright 2010 Joshua D Carter. All rights reserved.

Redistribution and use in source and binary forms, with or without modification, are
permitted provided that the following conditions are met:

1. Redistributions of source code must retain the above copyright notice, this list of
   conditions and the following disclaimer.

2. Redistributions in binary form must reproduce the above copyright notice, this list
   of conditions and the following disclaimer in the documentation and/or other materials
   provided with the distribution.

THIS SOFTWARE IS PROVIDED BY JOSHUA D CARTER ``AS IS'' AND ANY EXPRESS OR IMPLIED
WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND
FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL JOSHUA D CARTER OR
CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON
ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING
NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF
ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

The views and conclusions contained in the software and documentation are those of the
authors and should not be interpreted as representing official policies, either expressed
or implied, of Joshua D Carter.