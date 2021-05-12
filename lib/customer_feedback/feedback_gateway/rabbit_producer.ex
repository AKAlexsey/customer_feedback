defmodule CustomerFeedback.FeedbackGateway.RabbitProducer do
  @moduledoc """
  Put data into rabbit MQ queue
  """

  use GenServer

  @queue_name Application.get_env(:customer_feedback, CustomerFeedback.FeedbackGateway.Broadway)[
                :queue_name
              ]

  # API
  @doc """
  Put message to the RabbitMQ queue.
  Expect binary message (JSON or plain text)
  """
  def put_message(message) when is_binary(message) do
    GenServer.cast(__MODULE__, {:put_message, message})
  end

  # Callbacks
  def start_link(_) do
    GenServer.start_link(__MODULE__, [], name: __MODULE__)
  end

  def init(_) do
    {:ok, connection} = AMQP.Connection.open()
    {:ok, channel} = AMQP.Channel.open(connection)
    AMQP.Queue.declare(channel, @queue_name, durable: true)

    {:ok, %{channel: channel, connection: connection}}
  end

  def handle_cast({:put_message, message}, %{channel: channel} = state) do
    AMQP.Basic.publish(channel, "", @queue_name, message)

    {:noreply, state}
  end

  # TODO some why does not work
  def terminate(reason, %{connection: connection} = state) do
    IO.puts("!!! closing connection #{inspect(connection)}, reason: #{reason}")
    AMQP.Connection.close(connection)

    reason
  end
end
