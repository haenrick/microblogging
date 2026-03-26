require "test_helper"

class BlocksControllerTest < ActionDispatch::IntegrationTest
  setup do
    @blocker = users(:one)
    @target  = users(:two)
  end

  test "block creates block record" do
    sign_in_as(@blocker)
    assert_difference("Block.count", 1) do
      post block_user_path(@target.username)
    end
    assert_redirected_to profile_path(@target.username)
  end

  test "unblock removes block record" do
    sign_in_as(@blocker)
    @blocker.blocks.create!(blocked: @target)
    assert_difference("Block.count", -1) do
      delete unblock_user_path(@target.username)
    end
    assert_redirected_to profile_path(@target.username)
  end
end
