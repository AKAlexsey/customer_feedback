defmodule CustomerFeedback.FeedbackGateway.ConverterBroadway do
  use Broadway

  alias CustomerFeedback.FeedbackGateway.JsonBroadwayProducer

  alias CustomerFeedback.FeedbackGateway.RabbitClient

  @processors_count Application.get_env(:customer_feedback, __MODULE__)[:processors_count]

  def push_element(customer_id, feedback) when is_binary(customer_id) and is_map(feedback) do
    [producer_name | _] = Broadway.producer_names(__MODULE__)
    GenStage.cast(producer_name, {:push_element, customer_id, feedback})
  end

  # Callbacks
  def start_link(_opts) do
    Broadway.start_link(
      __MODULE__,
      name: __MODULE__,
      producer: [
        module: {JsonBroadwayProducer, []},
        # Must always be 1. Because in push_element API method, taken only the first producer
        concurrency: 1,
        rate_limiting: [
          allowed_messages: 3000,
          interval: 60_000
        ]
      ],
      processors: [
        default: [concurrency: @processors_count]
      ]
    )
  end

  @impl true
  def handle_message(_, %{data: {customer_id, feedback_params}} = message, _context) do
    feedback_params
    |> Map.put("customer_id", customer_id)
    |> Jason.encode!()
    |> RabbitClient.put_message()

    message
  end
end
