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
end
