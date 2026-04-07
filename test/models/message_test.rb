require "test_helper"

class MessageTest < ActiveSupport::TestCase
  setup do
    @sender    = users(:one)
    @recipient = users(:two)
  end

  test "valid message saves" do
    msg = Message.new(sender: @sender, recipient: @recipient, content: "Hi!")
    assert msg.valid?
  end

  test "content is required" do
    msg = Message.new(sender: @sender, recipient: @recipient, content: "")
    assert_not msg.valid?
  end

  test "content max 1000 chars" do
    msg = Message.new(sender: @sender, recipient: @recipient, content: "x" * 1001)
    assert_not msg.valid?
  end

  test "conversation_between returns messages in both directions" do
    msgs = Message.conversation_between(@sender, @recipient)
    assert_includes msgs, messages(:one)
    assert_includes msgs, messages(:two)
  end

  test "read? returns false when read_at is nil" do
    assert_not messages(:one).read?
  end
end
