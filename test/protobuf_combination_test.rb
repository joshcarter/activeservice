require 'rubygems'
require 'test/unit'
require 'live_resource'

require_resource File.join(File.dirname(__FILE__), 'protos', 'protobuf_combination_test')

class CompositeMessageTest < Test::Unit::TestCase
  TMP_FILE = File.join(File.dirname(__FILE__), 'composite.dat')

  def test_can_combine_proto_buffers
    # Create two protobufs, the Header containing the encoded Message
    #
    message1 = Test::Message.new
    message1.foo = 'this is foo'
    message1.baz = 'this is baz'
    # intentionally leaving message1.bar empty
    
    header1 = Test::Header.new
    header1.name = message1.class.to_s
    header1.status = Test::Header::MessageStatus::QUEUED
    # Serialize message to the bytes field in Header
    header1.message = message1.serialize_to_string

    File.open(TMP_FILE, 'w') { |f| header1.serialize_to(f) }

    # Read them back
    header2 = Test::Header.new

    File.open(TMP_FILE, 'r') { |f| header2.parse_from(f) }
    File.unlink(TMP_FILE)

    # Use class information saved in the header to create the message.
    #
    scope, const_name = nil, nil
    header2.name.split('::').reduce(Object) { |scope, const_name| scope.const_get(const_name) }
    klass = scope.const_get(const_name)

    # Create new message
    message2 = klass.new
    message2.parse_from_string(header2.message)
    
    assert_equal 'Test::Message', header2.name
    assert_equal Test::Header::MessageStatus::QUEUED, header2.status
    assert_equal 'this is foo', message2.foo
    assert_equal 'this is baz', message2.baz
    assert_equal false, message2.has_field?('bar') # left bar empty above
  end
end
