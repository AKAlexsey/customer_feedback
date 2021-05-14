defmodule CustomerFeedback.ElasticsearchApiMock do
  @behaviour Elasticsearch.API

  @impl true
  def request(_config, :get, "/customer_feedback/nont_existing", _data, _opts) do
    {:ok, %HTTPoison.Response{
      status_code: 404,
      body: %{
        "status" => "not_found"
      }
    }}
  end
end