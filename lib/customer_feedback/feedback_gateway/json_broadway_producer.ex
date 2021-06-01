defmodule CustomerFeedback.FeedbackGateway.JsonBroadwayProducer do
  @moduledoc "Receive messages wrap into %Broadway.Message{} and forward them to the processors"

  use GenServer

  alias Broadway.Message

  alias CustomerFeedback.FeedbackGateway.ConverterBroadway

  def start_link(_initial) do
    GenStage.start_link(__MODULE__, [], name: __MODULE__)
  end

  def init(_) do
    {:producer, %{}, []}
  end

  def handle_cast({:push_element, customer_id, feedback}, state) do
    message = %Message{
      data: {customer_id, feedback},
      acknowledger: {__MODULE__, :ack_id, :ack_data}
    }

    {:noreply, [message], state}
  end

  def ack(:ack_id, _successful, _failed) do
    :ok
  end

  def handle_demand(demand, state) do
    {:noreply, [], state}
  end
end
