require 'rubygems'
require 'test/unit'
require 'mocha'
require 'active_service'

class FakeService < ActiveService::Base
end

class EnumerationTest < Test::Unit::TestCase
  # Helper method to run a block with a certain number of services present.
  def with_services(n, &block)
    services = Array.new(n) { |i| "Service #{i + 1}" }
    FakeService.stubs(:find).with(:all).returns(services)

    block.call
  end

  def test_select_one_service_with_none_present
    with_services(0) do
      assert_raise(ActiveService::NoServicesRegistered) do
        service = FakeService.exactly_one
      end
    end
  end
  
  def test_select_one_service_with_one_present
    with_services(1) do
      service = FakeService.exactly_one
      assert_equal "Service 1", service
    end
  end
  
  def test_select_one_service_with_many_present
    with_services(2) do
      assert_raise(ActiveService::MoreServicesRegistered) do
        service = FakeService.exactly_one
      end
    end
  end
end