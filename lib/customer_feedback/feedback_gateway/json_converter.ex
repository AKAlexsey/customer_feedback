defmodule CustomerFeedback.FeedbackGateway.JsonConverter do
  @moduledoc """
  Convert feedback into JSON. Adds customer_id to other fields than puts data to the RabbitMQ queue for newly created feedbacks.
  """

  use GenServer

  @demand_atom :ask_demand

  alias CustomerFeedback.FeedbackGateway.JsonProducer
  alias CustomerFeedback.FeedbackGateway.RabbitProducer

  def push_element(customer_id, feedback) when is_binary(customer_id) and is_map(feedback) do
    GenStage.cast(__MODULE__, {:push_element, customer_id, feedback})
  end

  def start_link(opts) do
    process_name = get_process_name(opts)
    GenStage.start_link(__MODULE__, [], name: process_name)
  end

  def init(_) do
    {:consumer, %{subscription: nil}, subscribe_to: [JsonProducer]}
  end

  def handle_events([{customer_id, feedback_params}] = events, _from, state) do
    feedback_params
    |> Map.put("customer_id", customer_id)
    |> Jason.encode!()
    |> RabbitProducer.put_message()

    {:noreply, [], state}
  end

  def handle_subscribe(:producer, subscription_options, from, state) do
    schedule_demand()
    {:manual, %{state | subscription: from}}
  end

  def handle_info(@demand_atom, %{subscription: subscription} = state) do
    GenStage.ask(subscription, 1, [:noconnect])
    schedule_demand()
    {:noreply, [], state}
  end

  defp get_process_name(opts) do
    Keyword.get(opts, :id)
    |> case do
         nil ->
           raise ArgumentError, "Opts must contain :id. But it's absent. Given opts: #{inspect(opts)}"
         id ->
           String.to_atom("#{__MODULE__}_#{id}")

       end
  end

  defp schedule_demand do
    Process.send_after(self(), @demand_atom, 1000)
  end
end
