require "test_helper"

class FollowsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @follower = users(:one)
    @target   = users(:two)
  end

  test "follow creates follow record" do
    sign_in_as(@follower)
    assert_difference("Follow.count", 1) do
      post follow_user_path(@target.username)
    end
    assert_redirected_to profile_path(@target.username)
  end

  test "unfollow removes follow record" do
    sign_in_as(@follower)
    @follower.follows.create!(following: @target)
    assert_difference("Follow.count", -1) do
      delete unfollow_user_path(@target.username)
    end
    assert_redirected_to profile_path(@target.username)
  end
end
