require File::join(File::dirname(__FILE__), 'test_helper')
require 'active_service'

class FakeService < ActiveService::Base
  def self.create_instance(descriptor)
    # The descriptor is mocked (below) to be just a string, return that.
    descriptor
  end
end

class EnumerationTest < Test::Unit::TestCase
  # Helper method to run a block with a certain number of services present.
  def with_services(n, &block)
    services = Array.new(n) { |i| "Service #{i + 1}" }
    FakeService.stubs(:find).with(:all).returns(services)

    block.call
  end

  def test_enumeration_with_none_present
    with_services(0) do
      # Both with_one and with_exactly_one should raise when no services
      # are present.
      assert_raise(ActiveService::NoServicesRegistered) do
        FakeService.with_exactly_one do |service|
          assert false # Will not get here
        end
      end

      assert_raise(ActiveService::NoServicesRegistered) do
        FakeService.with_one do |service|
          assert false # Will not get here
        end
      end

      # Each should not raise, but just do nothing.
      FakeService.each do |service|
        assert false # Will not get here
      end
    end
  end
  
  def test_select_one_service_with_one_present
    with_services(1) do
      FakeService.with_exactly_one do |service|
        assert_equal "Service 1", service
      end

      FakeService.with_one do |service|
        assert_equal "Service 1", service
      end

      count = 0
      FakeService.each do |service|
        count += 1
      end
      assert_equal 1, count
    end
  end
  
  def test_select_one_service_with_many_present
    with_services(2) do
      assert_raise(ActiveService::MoreServicesRegistered) do
        FakeService.with_exactly_one do |service|
          assert false # Will not get here
        end
      end

      FakeService.with_one do |service|
        assert (service == "Service 1") or (service == "Service 2")
      end

      count = 0
      FakeService.each do |service|
        count += 1
      end
      assert_equal 2, count
    end
  end
end
