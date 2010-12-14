require 'rubygems'
require 'test/unit'
require 'active_service'
require 'redis'

# NOTE: this test requires a live Redis server and DNS-SD advertising 
# the service as type "_redis._tcp".

class RedisService < ActiveService::Base
  self.type = 'redis'

  def self.create_instance(descriptor)
    Redis.new(:host => descriptor.host, :port => descriptor.port)
  end
end

class RedisTest < Test::Unit::TestCase
  def test_access_exactly_one_redis_service
    RedisService.with_exactly_one do |redis|
      redis['foo'] = 'bar'
      
      assert_equal 'bar', redis['foo']
    end

    # Since we have exactly one redis service, we should be able
    # to connect to it again and re-read the key.
    RedisService.with_exactly_one do |redis|
      assert_equal 'bar', redis['foo']
    end
  end

  def test_enumerate_redis_services
    count = 0
    
    RedisService.each do |redis|
      assert(redis.is_a? Redis)
      count += 1
    end

    assert_equal 1, count
  end
end
