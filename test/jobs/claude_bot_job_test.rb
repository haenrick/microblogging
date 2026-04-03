require "test_helper"

class ClaudeBotJobTest < ActiveJob::TestCase
  setup do
    @post     = posts(:one)
    @bot_user = users(:claude_bot)
  end

  test "does nothing when ANTHROPIC_API_KEY is not set" do
    with_env("ANTHROPIC_API_KEY" => nil) do
      assert_no_difference("Post.count") do
        ClaudeBotJob.perform_now(@post)
      end
    end
  end

  test "creates a reply post with the API response" do
    with_env("ANTHROPIC_API_KEY" => "sk-test") do
      stub_anthropic("Hello back!") do
        assert_difference("Post.count", 1) do
          ClaudeBotJob.perform_now(@post)
        end
      end
    end

    reply = @post.replies.order(:created_at).last
    assert_equal @bot_user, reply.user
    assert_equal "Hello back!", reply.content
  end

  test "does not raise on API error" do
    with_env("ANTHROPIC_API_KEY" => "sk-test") do
      stub_anthropic_error do
        assert_nothing_raised { ClaudeBotJob.perform_now(@post) }
      end
    end
  end

  test "mention of @claude enqueues ClaudeBotJob" do
    poster = users(:two)
    assert_enqueued_with(job: ClaudeBotJob) do
      poster.posts.create!(
        content:    "hey @claude what is Ruby?",
        public_id:  SecureRandom.urlsafe_base64(8),
        expires_at: 30.days.from_now
      )
    end
  end

  test "mention of @claude does not create a mention notification" do
    poster = users(:two)
    assert_no_difference("Notification.count") do
      poster.posts.create!(
        content:    "hey @claude what is Ruby?",
        public_id:  SecureRandom.urlsafe_base64(8),
        expires_at: 30.days.from_now
      )
    end
  end

  private

  def stub_anthropic(text, &block)
    fake_response = { "content" => [ { "text" => text } ] }
    fake_client   = Object.new
    fake_client.define_singleton_method(:messages) { |**_| fake_response }
    stub_method(Anthropic::Client, :new, ->(*) { fake_client }, &block)
  end

  def stub_anthropic_error(&block)
    bad_client = Object.new
    bad_client.define_singleton_method(:messages) { |**_| raise "API error" }
    stub_method(Anthropic::Client, :new, ->(*) { bad_client }, &block)
  end

  def with_env(vars)
    original = vars.keys.each_with_object({}) { |k, h| h[k] = ENV[k] }
    vars.each { |k, v| v.nil? ? ENV.delete(k) : ENV[k] = v }
    yield
  ensure
    original.each { |k, v| v.nil? ? ENV.delete(k) : ENV[k] = v }
  end
end
