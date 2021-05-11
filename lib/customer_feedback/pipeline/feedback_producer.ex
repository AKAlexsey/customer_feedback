defmodule CustomerFeedback.Pipeline.FeedbackProducer do
  use GenStage

  def start_link(_) do
    GenStage.start_link(__MODULE__, [])
  end

  @impl true
  def init(_) do
    {:producer, []}
  end

  @impl true
  def handle_cast(info, state) do
    IO.puts("!!! handle_cast #{inspect(info)}")

    {:noreply, make_message(info), state}
  end

  @impl true
  def handle_demand(demand, state) when demand > 0 do
    rand = :rand.uniform(10)
    IO.puts("!!! demand #{inspect(demand)}, rand #{rand}")

    {:noreply, make_message(rand), state}
  end

  defp make_message(term), do: List.wrap(term)
end

#iex(3)> alias CustomerFeedback.Pipeline.FeedbackProducer
#CustomerFeedback.Pipeline.FeedbackProducer
#iex(4)> GenStage.cast(FeedbackProducer, 3)

