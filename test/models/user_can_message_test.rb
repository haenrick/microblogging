require "test_helper"

class UserCanMessageTest < ActiveSupport::TestCase
  setup do
    @alice = users(:one)
    @bob   = users(:two)
  end

  test "can_message? true when target follows self" do
    Follow.create!(follower: @bob, following: @alice, status: "accepted")
    assert @alice.can_message?(@bob)
  end

  test "can_message? false when target does not follow self" do
    assert_not @alice.can_message?(@bob)
  end

  test "can_message? false when blocking target" do
    Follow.create!(follower: @bob, following: @alice, status: "accepted")
    Block.create!(blocker: @alice, blocked: @bob)
    assert_not @alice.can_message?(@bob)
  end

  test "can_message? false when blocked by target" do
    Follow.create!(follower: @bob, following: @alice, status: "accepted")
    Block.create!(blocker: @bob, blocked: @alice)
    assert_not @alice.can_message?(@bob)
  end

  test "can_message? false when messaging self" do
    assert_not @alice.can_message?(@alice)
  end

  test "unread_messages_count returns correct count" do
    assert_equal 1, @alice.unread_messages_count  # messages(:one) is unread, to @alice
  end
end
