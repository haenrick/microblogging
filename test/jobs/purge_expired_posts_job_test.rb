require "test_helper"

class PurgeExpiredPostsJobTest < ActiveJob::TestCase
  test "deletes expired posts" do
    assert Post.where("expires_at <= ?", Time.current).exists?
    assert_difference("Post.count", -1) do
      PurgeExpiredPostsJob.perform_now
    end
  end

  test "leaves active posts untouched" do
    active_count = Post.active.count
    PurgeExpiredPostsJob.perform_now
    assert_equal active_count, Post.active.count
  end

  test "is idempotent when no expired posts remain" do
    PurgeExpiredPostsJob.perform_now
    assert_no_difference("Post.count") do
      PurgeExpiredPostsJob.perform_now
    end
  end
end
