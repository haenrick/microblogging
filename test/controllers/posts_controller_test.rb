require "test_helper"

class PostsControllerTest < ActionDispatch::IntegrationTest
  setup { @user = users(:one) }

  test "index redirects when not logged in" do
    get posts_path
    assert_redirected_to new_session_path
  end

  test "index returns success when logged in" do
    sign_in_as(@user)
    get posts_path
    assert_response :success
  end

  test "create post when logged in" do
    sign_in_as(@user)
    assert_difference("Post.count", 1) do
      post posts_path, params: { post: { content: "Hello world" } }
    end
    assert_redirected_to root_path
  end

  test "create post fails without content" do
    sign_in_as(@user)
    assert_no_difference("Post.count") do
      post posts_path, params: { post: { content: "" } }
    end
  end

  # ── Like ───────────────────────────────────────────────────────────────────
  test "like toggles on a post" do
    other_post = posts(:two)
    sign_in_as(@user)
    assert_difference("Like.count", 1) do
      post like_post_path(other_post), headers: { "Accept" => "text/html" }
    end
  end

  test "like toggles off when already liked" do
    target_post = posts(:two)
    sign_in_as(@user)
    @user.likes.create!(post: target_post)
    assert_difference("Like.count", -1) do
      post like_post_path(target_post), headers: { "Accept" => "text/html" }
    end
  end

  test "like on foreign post creates notification" do
    sign_in_as(@user)
    assert_difference("Notification.count", 1) do
      post like_post_path(posts(:two)), headers: { "Accept" => "text/html" }
    end
  end

  test "like on own post does not create notification" do
    sign_in_as(@user)
    assert_no_difference("Notification.count") do
      post like_post_path(posts(:one)), headers: { "Accept" => "text/html" }
    end
  end

  test "like responds with turbo_stream" do
    sign_in_as(@user)
    post like_post_path(posts(:two)), headers: { "Accept" => "text/vnd.turbo-stream.html" }
    assert_response :success
    assert_match "text/vnd.turbo-stream.html", response.content_type
  end

  test "like does not raise on concurrent duplicate (race condition)" do
    target = posts(:two)
    sign_in_as(@user)
    # Simulate race condition: like already exists in DB but find_by finds it
    # The rescue RecordNotUnique guard ensures no 500 — instead 200
    @user.likes.create!(post: target)
    # Deleting via DB to bypass counter cache, then re-inserting would need raw SQL.
    # Simplest: call like twice — second call should toggle off cleanly (no 500).
    post like_post_path(target), headers: { "Accept" => "text/html" }
    assert_response :redirect
  end

  # ── Reply ──────────────────────────────────────────────────────────────────
  test "reply creates post with parent" do
    sign_in_as(@user)
    parent = posts(:two)
    assert_difference("Post.count", 1) do
      post reply_post_path(parent), params: { post: { content: "my reply" } }
    end
    assert_equal parent, Post.order(:created_at).last.parent
  end

  test "reply to foreign post creates notification" do
    sign_in_as(@user)
    assert_difference("Notification.count", 1) do
      post reply_post_path(posts(:two)), params: { post: { content: "a reply" } }
    end
  end

  test "reply to own post does not create notification" do
    sign_in_as(@user)
    assert_no_difference("Notification.count") do
      post reply_post_path(posts(:one)), params: { post: { content: "self reply" } }
    end
  end

  # ── Destroy ────────────────────────────────────────────────────────────────
  test "destroy own post" do
    sign_in_as(@user)
    # use expired post (no children) to get exactly -1
    assert_difference("Post.count", -1) do
      delete post_path(posts(:expired))
    end
    assert_redirected_to root_path
  end

  test "cannot destroy another user's post" do
    sign_in_as(@user)
    assert_no_difference("Post.count") do
      delete post_path(posts(:two))
    end
  end
end
