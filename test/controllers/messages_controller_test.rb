require "test_helper"

class MessagesControllerTest < ActionDispatch::IntegrationTest
  setup do
    @alice = users(:one)
    @bob   = users(:two)
    # Bob follows Alice → Alice can message Bob
    @follow = Follow.create!(follower: @bob, following: @alice, status: "accepted")
  end

  teardown { @follow.destroy }

  test "inbox requires authentication" do
    get messages_path
    assert_redirected_to new_session_path
  end

  test "inbox shows conversations" do
    sign_in_as(@alice)
    get messages_path
    assert_response :success
    assert_match "usertwo", response.body
  end

  test "show conversation" do
    sign_in_as(@alice)
    get message_path(@bob.username)
    assert_response :success
    assert_match "Hallo userone", response.body
  end

  test "cannot view conversation without permission" do
    sign_in_as(@alice)
    @follow.destroy
    get message_path(@bob.username)
    assert_redirected_to messages_path
  end

  test "send message" do
    sign_in_as(@alice)
    assert_difference("Message.count", 1) do
      post message_path(@bob.username), params: { content: "Testinhalt" }
    end
    assert_redirected_to message_path(@bob.username)
  end

  test "cannot send message without permission" do
    sign_in_as(@alice)
    @follow.destroy
    assert_no_difference("Message.count") do
      post message_path(@bob.username), params: { content: "Testinhalt" }
    end
    assert_redirected_to messages_path
  end

  test "marks messages as read on show" do
    sign_in_as(@alice)
    assert_nil messages(:one).read_at
    get message_path(@bob.username)
    assert_not_nil messages(:one).reload.read_at
  end
end
