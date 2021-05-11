defmodule CustomerFeedback.Pipeline.FeedbackGatewayBroadway do
  use Broadway

  # Push messages to the processors
  # Broadway.push_messages(FeedbackGatewayBroadway, [FeedbackGatewayBroadway.transform(1, [])])

  alias Broadway.Message

  alias CustomerFeedback.Pipeline.FeedbackProducer

  def start_link(_opts) do
    Broadway.start_link(
      __MODULE__,
      name: __MODULE__,
      producer: [
        module: {FeedbackProducer, []},
        concurrency: 1,
        transformer: {__MODULE__, :transform, []}
      ],
      processors: [
        default: [concurrency: 4]
      ]
    )
  end

  @impl true
  def handle_message(processor, message, context) do
    IO.puts("!!! processor #{inspect(processor)}\nmessage #{inspect(message)}\ncontext #{inspect(context)}\npid: #{inspect(self)}")
    message
  end

  def transform(event, _opts) do
    %Message{
      data: event,
      acknowledger: {__MODULE__, :ack_id, :ack_data}
    }
  end

  def ack(:ack_id, successful, failed) do
    # Write ack code here
    :ok
  end
end