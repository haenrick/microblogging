require "test_helper"

class BlocksControllerTest < ActionDispatch::IntegrationTest
  setup do
    @blocker = users(:one)
    @target  = users(:two)
  end

  test "create redirects when not logged in" do
    post block_user_path(@target.username)
    assert_redirected_to new_session_path
  end

  test "create blocks the user" do
    sign_in_as(@blocker)
    assert_difference("Block.count", 1) do
      post block_user_path(@target.username)
    end
    assert_redirected_to profile_path(@target.username)
    assert @blocker.blocking?(@target)
  end

  test "create removes existing follows between both users" do
    sign_in_as(@blocker)
    @blocker.follows.create!(following: @target)
    @target.follows.create!(following: @blocker)

    post block_user_path(@target.username)

    assert_not @blocker.following?(@target)
    assert_not @target.following?(@blocker)
  end

  test "cannot block yourself" do
    sign_in_as(@blocker)
    assert_no_difference("Block.count") do
      post block_user_path(@blocker.username)
    end
  end

  test "destroy redirects when not logged in" do
    delete unblock_user_path(@target.username)
    assert_redirected_to new_session_path
  end

  test "destroy removes the block" do
    sign_in_as(@blocker)
    @blocker.blocks.create!(blocked: @target)
    assert_difference("Block.count", -1) do
      delete unblock_user_path(@target.username)
    end
    assert_redirected_to profile_path(@target.username)
  end
end
