defmodule CustomerFeedback.Pipeline.FeedbackGatewayBroadway do
  use Broadway

  # Push messages to the processors
  # Broadway.push_messages(FeedbackGatewayBroadway, [FeedbackGatewayBroadway.transform(1, [])])

  alias Broadway.Message

  alias CustomerFeedback.Pipeline.FeedbackProducer

  # Public API
  # TODO there is problem every 4 feedbacks forward to the same processor.
  # And after that it generates one demand. It's very strange behaviour it's necessary to find out why it happens
  def get_customer_feedback(message) do
    __MODULE__
    |> Broadway.producer_names()
    |> Enum.each(fn name ->
      GenStage.cast(name, message)
    end)
  end

  # Callbacks
  def start_link(_opts) do
    Broadway.start_link(
      __MODULE__,
      name: __MODULE__,
      producer: [
        module: {FeedbackProducer, []},
        concurrency: 1,
        transformer: {__MODULE__, :transform, []},
        rate_limiting: [
          allowed_messages: 60,
          interval: 60_000
        ]
      ],
      processors: [
        default: [concurrency: 4]
      ]
    )
  end

  @impl true
  def handle_message(processor, message, context) do
    IO.puts("!!! processor #{inspect(processor)}\nmessage #{inspect(message)}\ncontext #{inspect(context)}\npid: #{inspect(self())}")
    message
  end

  def transform(event, _opts) do
    %Message{
      data: event,
      acknowledger: {__MODULE__, :ack_id, :ack_data}
    }
  end

  def ack(:ack_id, _successful, _failed) do
    :ok
  end
end