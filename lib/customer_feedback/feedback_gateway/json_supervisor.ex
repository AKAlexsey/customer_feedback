defmodule CustomerFeedback.FeedbackGateway.JsonSupervisor do
  @moduledoc "Contains whole converter tree"

  use Supervisor

  alias CustomerFeedback.FeedbackGateway.{JsonConverter, JsonProducer}

  @converters_count Application.get_env(:customer_feedback, JsonConverter)[:workers_count]

  def start_link(arg) do
    Supervisor.start_link(__MODULE__, arg, name: __MODULE__)
  end

  @impl true
  def init(_arg) do
    converters =
      Enum.map(1..@converters_count, fn number ->
        Supervisor.child_spec({JsonConverter, [id: number]}, id: number)
      end)

    children = [Supervisor.child_spec({JsonProducer, []}, id: JsonProducer)] ++ converters

    Supervisor.init(children, strategy: :one_for_one, name: __MODULE__)
  end
end
