require File::join(File::dirname(__FILE__), 'test_helper')
require 'active_service'

class InterfaceRestrictionTest < Test::Unit::TestCase
  def test_no_restriction
    DNSSD.expects(:browse).with('_foo._tcp', nil, 0, DNSSD::InterfaceAny)

    ActiveService::Browser.new('foo', 'tcp')
  end

  def test_restrict_to_loopback
    interface_index = DNSSD::interface_index 'lo0'
    DNSSD.expects(:browse).with('_foo._tcp', nil, 0, interface_index)

    ActiveService::Browser.new('foo', 'tcp', 'lo0')
  end
end