defmodule CustomerFeedback.Application do
  @moduledoc false

  use Application

  def start(_type, _args) do
    children = [
      CustomerFeedback.Repo,
      CustomerFeedbackWeb.Telemetry,
      # {Phoenix.PubSub, name: CustomerFeedback.PubSub}, # commented because does not used for a while.
      CustomerFeedbackWeb.Endpoint,
      CustomerFeedback.ElasticsearchCluster,
      {CustomerFeedback.FeedbackGateway.Broadway, []},
      CustomerFeedback.FeedbackGateway.RabbitProducer
    ]

    opts = [strategy: :one_for_one, name: CustomerFeedback.Supervisor]
    Supervisor.start_link(children, opts)
  end

  def config_change(changed, _new, removed) do
    CustomerFeedbackWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
