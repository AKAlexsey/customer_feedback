use Mix.Config

config :customer_feedback, CustomerFeedback.Repo,
  username: "postgres",
  password: "postgres",
  database: "customer_feedback_dev",
  hostname: "localhost",
  show_sensitive_data_on_connection_error: true,
  pool_size: 10

config :customer_feedback, CustomerFeedbackWeb.Endpoint,
  http: [port: 4000],
  debug_errors: true,
  code_reloader: true,
  check_origin: false,
  watchers: [
    node: [
      "node_modules/webpack/bin/webpack.js",
      "--mode",
      "development",
      "--watch-stdin",
      cd: Path.expand("../assets", __DIR__)
    ]
  ]

config :customer_feedback, CustomerFeedback.ElasticsearchCluster,
  url: "http://localhost:9200",
  username: "elastic",
  password: "changeme",
  api: Elasticsearch.API.HTTP,
  json_library: Jason,
  default_options: [
    timeout: 5_000,
    recv_timeout: 5_000,
    hackney: [pool: :pool_name]
  ],
  indexes: %{
    feedback_documents: %{
      settings: "/home/carefreeslacker/RubymineProjects/customer_feedback/elastic_configs/feedback_documents.json",
      store: CustomerFeedback.ElasticsearchStore,
      sources: [CustomerFeedback.CustomerInput.FeedbackDocument],
      bulk_page_size: 5000,
      bulk_wait_interval: 15_000
    }
  }

config :customer_feedback, CustomerFeedback.FeedbackGateway.Broadway,
  queue_name: "customer_feedback_queue"

# ## SSL Support
#
# In order to use HTTPS in development, a self-signed
# certificate can be generated by running the following
# Mix task:
#
#     mix phx.gen.cert
#
# Note that this task requires Erlang/OTP 20 or later.
# Run `mix help phx.gen.cert` for more information.
#
# The `http:` config above can be replaced with:
#
#     https: [
#       port: 4001,
#       cipher_suite: :strong,
#       keyfile: "priv/cert/selfsigned_key.pem",
#       certfile: "priv/cert/selfsigned.pem"
#     ],
#
# If desired, both `http:` and `https:` keys can be
# configured to run both http and https servers on
# different ports.

# Watch static and templates for browser reloading.
config :customer_feedback, CustomerFeedbackWeb.Endpoint,
  live_reload: [
    patterns: [
      ~r"priv/static/.*(js|css|png|jpeg|jpg|gif|svg)$",
      ~r"priv/gettext/.*(po)$",
      ~r"lib/customer_feedback_web/(live|views)/.*(ex)$",
      ~r"lib/customer_feedback_web/templates/.*(eex)$"
    ]
  ]

# Do not include metadata nor timestamps in development logs
config :logger, :console, format: "[$level] $message\n"

# Set a higher stacktrace during development. Avoid configuring such
# in production as building large stacktraces may be expensive.
config :phoenix, :stacktrace_depth, 20

# Initialize plugs at runtime for faster development compilation
config :phoenix, :plug_init_mode, :runtime
