defmodule CustomerFeedback.FeedbackGateway.Broadway do
  use Broadway

  # Push messages to the processors
  # Broadway.push_messages(FeedbackGatewayBroadway, [FeedbackGatewayBroadway.transform(1, [])])



  alias Broadway.Message

  # alias CustomerFeedback.Pipeline.FeedbackProducer

  @queue_name Application.get_env(:customer_feedback, __MODULE__)[:queue_name]

  # Callbacks
  def start_link(_opts) do
    Broadway.start_link(
      __MODULE__,
      name: __MODULE__,
      producer: [
        module: {BroadwayRabbitMQ.Producer, queue: @queue_name},
        concurrency: 1,
        transformer: {__MODULE__, :transform, []},
        rate_limiting: [
          allowed_messages: 60,
          interval: 60_000
        ]
      ],
      processors: [
        default: [concurrency: 5]
      ]
    )
  end

  # TODO implement bulk document insertion using Broadway batching
  # Input document
  # Elasticsearch.post_document(CustomerFeedback.ElasticsearchCluster, %CustomerFeedback.CustomerInput.FeedbackDocument{title: "Example", author: "Willie wonka", evaluation: 9}, "feedback_documents")
  #
  @impl true
  def handle_message(_, message, context) do
    IO.puts("!!! processor\nmessage #{inspect(message)}\ncontext #{inspect(context)}\npid: #{inspect(self())}")
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