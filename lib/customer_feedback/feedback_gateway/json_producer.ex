defmodule CustomerFeedback.FeedbackGateway.JsonProducer do
  @moduledoc "Stores newly coming messages"

  use GenServer

  def push_element(customer_id, feedback) when is_binary(customer_id) and is_map(feedback) do
    GenStage.cast(__MODULE__, {:push_element, customer_id, feedback})
  end

  def start_link(_initial) do
    GenStage.start_link(__MODULE__, [], name: __MODULE__)
  end

  def init(_) do
    {:producer, :queue.new(), dispatcher: GenStage.DemandDispatcher}
  end

  def handle_cast({:push_element, customer_id, feedback}, queue) do
    {:noreply, [], :queue.in({customer_id, feedback}, queue)}
  end

  def handle_demand(_, queue) do
    queue
    |> :queue.out()
    |> case do
      {:empty, empty_queue} ->
        {:noreply, [], empty_queue}

      {{:value, value}, updated_queue} ->
        {:noreply, [value], updated_queue}
    end
  end
end
