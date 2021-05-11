defmodule CustomerFeedback.Application do
  @moduledoc false

  use Application

  alias CustomerFeedback.Pipeline.FeedbackProducer

  def start(_type, _args) do
    children = [
      CustomerFeedback.Repo,
      CustomerFeedbackWeb.Telemetry,
      # {Phoenix.PubSub, name: CustomerFeedback.PubSub}, # commented because does not used for a while.
      CustomerFeedbackWeb.Endpoint,
      CustomerFeedback.ElasticsearchCluster,
      {CustomerFeedback.Pipeline.FeedbackGatewayBroadway, []},
      FeedbackProducer
    ]

    opts = [strategy: :one_for_one, name: CustomerFeedback.Supervisor]
    Supervisor.start_link(children, opts)
  end

  def config_change(changed, _new, removed) do
    CustomerFeedbackWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
