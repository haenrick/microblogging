class PurgeExpiredPostsJob < ApplicationJob
  queue_as :default

  def perform
    Post.where("expires_at <= ?", Time.current).destroy_all
  end
end
