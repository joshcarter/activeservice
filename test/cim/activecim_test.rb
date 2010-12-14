require 'rubygems'
require 'test/unit'
require 'active_service'
require 'active_cim/base'

# NOTE: this test requires a live CIMOM, a provider for CIM_NetworkPort, and
# DNS-SD advertising the service as type "_cimxml._tcp".

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

class CimTest < Test::Unit::TestCase
  def test_can_access_logical_ports_directly
    ports = CimService.network_ports

    # Assume system has at least one network port.
    assert ports.length > 0

    # Assume system has at least one loopback port.
    assert_not_nil ports.find { |p| p.name.match /^lo/ }
  end
end

