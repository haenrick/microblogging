class PurgeExpiredPostsJob < ApplicationJob
  queue_as :default

  def perform
    Post.where("expires_at <= ?", Time.current).delete_all
  end
end
