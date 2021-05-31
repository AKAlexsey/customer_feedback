defmodule CustomerFeedback.FeedbackGateway.Broadway do
  use Broadway

  alias Broadway.Message
  alias CustomerFeedback.Elasticsearch.Context, as: ElasticsearchContext

  @queue_name Application.get_env(:customer_feedback, __MODULE__)[:queue_name]
  @allowed_messages Application.get_env(:customer_feedback, __MODULE__)[:allowed_messages]
  @interval_allowed_messages Application.get_env(:customer_feedback, __MODULE__)[
                               :interval_allowed_messages
                             ]
  @processors_concurrency Application.get_env(:customer_feedback, __MODULE__)[
                            :processors_concurrency
                          ]
  @elastic_batchers_concurrency Application.get_env(:customer_feedback, __MODULE__)[
                                  :elastic_batchers_concurrency
                                ]
  @elastic_batch_size Application.get_env(:customer_feedback, __MODULE__)[:elastic_batch_size]

  # Callbacks
  def start_link(_opts) do
    Broadway.start_link(
      __MODULE__,
      name: __MODULE__,
      producer: [
        module:
          {BroadwayRabbitMQ.Producer,
           queue: @queue_name,
           on_success: :ack,
           on_failure: :reject_and_requeue_once,
           consume_options: [no_ack: true]},
        concurrency: 1,
        transformer: {__MODULE__, :transform, []},
        rate_limiting: [
          allowed_messages: @allowed_messages,
          interval: @interval_allowed_messages
        ]
      ],
      processors: [
        default: [concurrency: @processors_concurrency]
      ],
      batchers: [
        elastic: [
          concurrency: @elastic_batchers_concurrency,
          batch_size: @elastic_batch_size,
          partition_by: &partition/1
        ]
      ],
      context:
        "Could be anything, even function. Passed as third argument to the handle_message and handle_batch"
    )
  end

  defp partition(%{data: %{"customer_id" => customer_id}}) do
    {customer_key, _} = Integer.parse(String.at(customer_id, -1))
    customer_key
  end

  # Convert input data into Broadway.Message format
  # Must define acknowledger
  def transform(event, _opts) do
    %Message{
      data: event,
      acknowledger: {__MODULE__, :ack_id, :ack_data}
    }
  end

  @impl true
  def handle_message(_, message, _context) do
    # Dynamic batching example. Requires handle_batch with according pattern matching in batch_info
    # decoded = Jason.decode!(message.data.data)
    # {evaluation, _} = Integer.parse(decoded["evaluation"])
    # batch_key = if(evaluation > 3, do: :good, else: :bad)
    # message
    # |> Broadway.Message.put_batcher(:elastic)
    # |> Broadway.Message.put_batch_key(batch_key)

    message
    |> Broadway.Message.put_batcher(:elastic)
    |> Broadway.Message.update_data(&Jason.decode!(&1.data))
  end

  # Invoked after handle_message if batching is absent
  # Invoked after handle_batch if batching is present
  def ack(:ack_id, _successful, _failed) do
    :ok
  end

  @impl true
  def handle_batch(:elastic, messages, _batch_info, _context) do
    # TODO working only after fixing Elasticsearch.Index.Bulk fix
    # Replaced header/4 function second argument "create" to "index"
    messages
    |> Enum.map(& &1.data)
    |> ElasticsearchContext.create_feedback_documents_in_batch()

    messages
  end

  # Invoked after handle_message or handle_batch in case when
  # batching is turned off or on accordingly
  @impl true
  def handle_failed(messages, _context) do
    messages
  end
end
