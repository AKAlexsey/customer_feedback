use Mix.Config

# Configure your database
#
# The MIX_TEST_PARTITION environment variable can be used
# to provide built-in test partitioning in CI environment.
# Run `mix help test` for more information.
config :customer_feedback, CustomerFeedback.Repo,
  username: "postgres",
  password: "postgres",
  database: "customer_feedback_test#{System.get_env("MIX_TEST_PARTITION")}",
  hostname: "localhost",
  pool: Ecto.Adapters.SQL.Sandbox

# We don't run a server during test. If one is required,
# you can enable the server option below.
config :customer_feedback, CustomerFeedbackWeb.Endpoint,
  http: [port: 4002],
  server: false

# Print only warnings and errors during test
config :logger, level: :warn

config :customer_feedback, CustomerFeedback.ElasticsearchCluster,
  api: CustomerFeedback.ElasticsearchApiMock

config :customer_feedback, CustomerFeedback.FeedbackGateway.Broadway,
  queue_name: "customer_feedback_queue",
  allowed_messages: 100,
  interval_allowed_messages: 60_000,
  processors_concurrency: 1,
  elastic_batchers_concurrency: 1,
  elastic_batch_size: 1
