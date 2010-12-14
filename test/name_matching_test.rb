require File::join(File::dirname(__FILE__), 'test_helper')
require 'active_service'

class DessertService < ActiveService::Base
  self.type = 'desserts'
  self.protocol = 'tcp'

  # Take everything.
  self.name_filter = nil
end

class IceCreamService < ActiveService::Base
  self.type = 'desserts'
  self.protocol = 'tcp'
  self.name_filter = /Ice Cream$/
end

class NameMatchingTest < Test::Unit::TestCase
  def setup
    @descriptors = Hash.new
    
    ["Vanilla Ice Cream", "Chocolate Ice Cream", "Tiramisu"].each do |name|
      @descriptors[name] = ActiveService::Descriptor.new(:name => name)
    end
    
    @browser = Object.new
    @browser.stubs(:all).returns(@descriptors)

    ActiveService::Browser.expects(:new).with('desserts', 'tcp').returns(@browser)
  end

  def test_no_name_matcher_discovers_all_services
    services = DessertService.find(:all)
    assert_equal 3, services.length
  end

  def test_name_matcher_prunes_services
    services = IceCreamService.find(:all)
    assert_equal 2, services.length
    assert_not_nil services.find { |s| s.name == "Vanilla Ice Cream" }
    assert_not_nil services.find { |s| s.name == "Chocolate Ice Cream" }
  end
end
