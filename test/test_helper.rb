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

    # How many SQL queries the block runs, counted the same way as assert_queries_count.
    # Tests run with the query cache on, so wrap both in ActiveRecord::Base.uncached to
    # count queries a real request would run, not ones answered from an earlier query.
    def count_queries(&block)
      ActiveRecord::Base.lease_connection.materialize_transactions
      counter = ActiveRecord::Assertions::QueryAssertions::SQLCounter.new
      ActiveSupport::Notifications.subscribed(counter, "sql.active_record", &block)
      counter.log.size
    end
  end
end
