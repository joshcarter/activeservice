ActiveService
=============

ActiveService is a lightweight framework built on [DNS Service Discovery][1], a/k/a the top level of Zeroconf/Bonjour. It allows you to easily define clients to network services, allowing your application to skip all the host/port configuration gunk, and instead pick network services dynamically.

[1]: http://www.dns-sd.org/

TODO: further detail here

- Late binding
- Instance name matching

Sample use:

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
        Redis.new(:host => descriptor[:host])
      end
      
      # Service may optionally provide this method if there's any cleanup
      # needed for the instances created in create_instance.
      def self.destroy_instance(instance)
        # Nothing needed, Redis objects clean up on their own
      end
    end
    
    # ...application code...
    
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
