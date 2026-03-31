ENV["RAILS_ENV"] ||= "test"
require_relative "../config/environment"
require "rails/test_help"
require_relative "test_helpers/session_test_helper"

module ActiveSupport
  class TestCase
    # Run tests in parallel with specified workers
    parallelize(workers: :number_of_processors)

    # Setup all fixtures in test/fixtures/*.yml for all tests in alphabetical order.
    fixtures :all

    # Temporarily replace a singleton method on any object/module for the duration
    # of a block. Works with minitest 6 which no longer ships minitest/mock.
    #
    #   stub_method(WebPush, :payload_send, ->(*) { calls += 1 }) { job.perform }
    def stub_method(obj, method_name, callable)
      original = obj.method(method_name)
      obj.define_singleton_method(method_name) { |*a, **k| callable.call(*a, **k) }
      yield
    ensure
      obj.define_singleton_method(method_name, &original)
    end
  end
end
