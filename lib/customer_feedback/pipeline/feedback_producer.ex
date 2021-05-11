defmodule CustomerFeedback.Pipeline.FeedbackProducer do
  use GenStage

  alias Broadway.Message

  def start_link(_) do
    GenStage.start_link(__MODULE__, [])
  end

  def init(_) do
    {:producer, []}
  end

  @impl true
  def handle_demand(demand, dummy_state) when demand > 0 do
    IO.puts("!!! demand #{inspect(demand)}")

    message =
      :rand.uniform(10)
      |> List.wrap()

    {:noreply, message, dummy_state}
  end
end
