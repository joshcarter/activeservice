require 'test_helper'
require 'active_service/browser'

class BrowserTest < Test::Unit::TestCase
  SERVICE_NAME = 'Test provider'
  SERVICE_TYPE = 'test_provider'
  
  def setup
    @browser = ActiveService::Browser.new(SERVICE_TYPE, 'tcp')
  end

  def teardown
    @browser.stop
  end

  def test_resolution_fails_with_no_service
    sleep 0.1
    assert_nil @browser[SERVICE_NAME]
  end

  def test_resolution_finds_service
    provider = TestProvider.new(:name => SERVICE_NAME, :type => SERVICE_TYPE)
    provider.wait_for_register

    sleep 1
    assert_equal SERVICE_NAME, @browser[SERVICE_NAME].name
    provider.stop
  end
end
