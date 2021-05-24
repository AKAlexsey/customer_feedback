defmodule CustomerFeedback.ElasticsearchStore do
  @behaviour Elasticsearch.Store

  alias CustomerFeedback.Repo

  @impl true
  def stream(schema) do
    Repo.stream(schema)
  end

  @impl true
  def transaction(fun) do
    {:ok, result} = Repo.transaction(fun, timeout: :infinity)
    result
  end
end
