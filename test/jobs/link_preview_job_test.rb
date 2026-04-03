require "test_helper"

class LinkPreviewJobTest < ActiveJob::TestCase
  setup do
    @post = posts(:one)
  end

  test "does nothing when post has no url" do
    @post.update_column(:content, "no link here")
    LinkPreviewJob.perform_now(@post)
    assert_nil @post.reload.link_preview
  end

  test "fetches og data and stores link_preview" do
    @post.update_column(:content, "check https://example.com")

    fake_html = <<~HTML
      <html><head>
        <title>Example</title>
        <meta property="og:title" content="OG Title">
        <meta property="og:description" content="A description">
        <meta property="og:site_name" content="Example Site">
      </head></html>
    HTML

    stub_method(URI, :open, ->(*_args, **_kwargs) { StringIO.new(fake_html) }) do
      LinkPreviewJob.perform_now(@post)
    end

    preview = @post.reload.link_preview
    assert_equal "OG Title", preview["title"]
    assert_equal "A description", preview["description"]
    assert_equal "Example Site", preview["site_name"]
  end

  test "does not raise on network error" do
    @post.update_column(:content, "check https://example.com")

    stub_method(URI, :open, ->(*_args, **_kwargs) { raise SocketError, "unreachable" }) do
      assert_nothing_raised { LinkPreviewJob.perform_now(@post) }
    end

    assert_nil @post.reload.link_preview
  end
end
