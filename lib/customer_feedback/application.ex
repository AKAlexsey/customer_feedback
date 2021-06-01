defmodule CustomerFeedback.Application do
  @moduledoc false

  use Application

  def start(_type, _args) do
    children = [
      CustomerFeedback.Repo,
      CustomerFeedbackWeb.Telemetry,
      {Phoenix.PubSub, name: CustomerFeedback.PubSub},
      CustomerFeedbackWeb.Endpoint,
      CustomerFeedback.ElasticsearchCluster,
      {CustomerFeedback.FeedbackGateway.Broadway, []},
      CustomerFeedback.FeedbackGateway.RabbitClient,
      CustomerFeedback.FeedbackGateway.JsonSupervisor,
      CustomerFeedback.FeedbackGateway.ConverterBroadway
    ]

    opts = [strategy: :one_for_one, name: CustomerFeedback.Supervisor]
    Supervisor.start_link(children, opts)
  end

  def config_change(changed, _new, removed) do
    CustomerFeedbackWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
