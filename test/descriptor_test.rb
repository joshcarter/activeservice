require 'rubygems'
require 'mocha'
require 'test/unit'
require 'active_service/descriptor'

class DescriptorTest < Test::Unit::TestCase
  def test_address_resolves_automatically
    descriptor = ActiveService::Descriptor.new(
      :host => 'fakehost')
    addrinfo = [["AF_INET", 0, "fakehost", "192.168.100.100", 2, 1, 6]]
    
    Socket.expects(:getaddrinfo).once.returns(addrinfo)
    
    # First call should resolve host
    assert_equal '192.168.100.100', descriptor.address
    
    # Second call should return cached value
    assert_equal '192.168.100.100', descriptor.address
  end

  def test_type_has_correct_form
    descriptor = ActiveService::Descriptor.new(
      :type => 'faketype',
      :protocol => 'fakeprotocol')
    
    assert_equal '_faketype._fakeprotocol', descriptor.type
  end

end