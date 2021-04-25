# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.

# General application configuration
use Mix.Config

config :customer_feedback,
  ecto_repos: [CustomerFeedback.Repo]

# Configures the endpoint
config :customer_feedback, CustomerFeedbackWeb.Endpoint,
  url: [host: "localhost"],
  secret_key_base: "h8v3HHgZiQK9TiaBuF0/SvjcQIJPhae1DFLYrBkBIclgNzEOiaB98Bq6dmVEUry1",
  render_errors: [view: CustomerFeedbackWeb.ErrorView, accepts: ~w(html json), layout: false],
  pubsub_server: CustomerFeedback.PubSub,
  live_view: [signing_salt: "zBO7hgYh"]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Use Jason for JSON parsing in Phoenix
config :phoenix, :json_library, Jason

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env()}.exs"
