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
        elastic: [concurrency: @elastic_batchers_concurrency, batch_size: @elastic_batch_size]
      ]
    )
  end

  # TODO implement bulk document insertion using Broadway batching
  # Input document
  # Elasticsearch.post_document(CustomerFeedback.ElasticsearchCluster, %CustomerFeedback.CustomerInput.FeedbackDocument{title: "Example", author: "Willie wonka", evaluation: 9}, "feedback_documents")
  #
  @impl true
  def handle_message(_, message, _context) do
    # TODO Add logging in case of invalid messages
    # Old before batching version of inserting message
    # result =
    #   raw_feedback_document
    #   |> Jason.decode!()
    #   |> ElasticsearchContext.create_feedback_document()

    message
    |> Broadway.Message.put_batcher(:elastic)
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

  @impl true
  def handle_batch(:elastic, messages, _batch_info, _context) do
    # TODO working only after fixing Elasticsearch.Index.Bulk fix
    # Replaced header/4 function second argument "create" to "index"
    messages
    |> Enum.map(fn %{data: %{data: raw_feedback_document}} ->
      Jason.decode!(raw_feedback_document)
    end)
    |> ElasticsearchContext.create_feedback_documents_in_batch()

    messages
  end
end
