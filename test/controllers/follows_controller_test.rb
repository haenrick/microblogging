require "test_helper"

class FollowsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @follower = users(:one)
    @target   = users(:two)
  end

  test "follow public profile creates accepted follow" do
    sign_in_as(@follower)
    assert_difference("Follow.count", 1) do
      post follow_user_path(@target.username)
    end
    assert_equal "accepted", Follow.last.status
    assert_redirected_to profile_path(@target.username)
  end

  test "follow private profile creates pending follow" do
    @target.update!(private_profile: true)
    sign_in_as(@follower)
    assert_difference("Follow.count", 1) do
      post follow_user_path(@target.username)
    end
    assert_equal "pending", Follow.last.status
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

  test "accept follow request updates status to accepted" do
    sign_in_as(@target)
    @follower.follows.create!(following: @target, status: "pending")
    patch accept_follow_request_path(@follower.username)
    assert_equal "accepted", Follow.find_by(follower: @follower, following: @target).status
    assert_redirected_to profile_path(@target.username)
  end

  test "decline follow request destroys the follow" do
    sign_in_as(@target)
    @follower.follows.create!(following: @target, status: "pending")
    assert_difference("Follow.count", -1) do
      delete decline_follow_request_path(@follower.username)
    end
    assert_redirected_to profile_path(@target.username)
  end

  test "accepting follow sends notification" do
    sign_in_as(@target)
    @follower.follows.create!(following: @target, status: "pending")
    assert_difference("Notification.count", 1) do
      patch accept_follow_request_path(@follower.username)
    end
  end
end
