require File::join(File::dirname(__FILE__), 'test_helper')
require 'active_service'

class FakeService < ActiveService::Base
end

class NameMatchingTest < Test::Unit::TestCase
  # Helper method to run a block with a certain number of services present.
  def with_services(n, &block)
    services = ["Vanilla Ice Cream", "Chocolate Ice Cream", "Tiramisu"]
    FakeService.stubs(:find).with(:all).returns(services)

    block.call
  end

  def test_true
    true
  end
end