defmodule CustomerFeedback.ElasticsearchApiMock do
  @behaviour Elasticsearch.API

  @impl true
  def request(_config, :get, _, _data, _opts) do
    {:ok, %HTTPoison.Response{
      status_code: 200,
      body: %{
        "status" => "not_found"
      }
    }}
  end

  def request(_config, :post, _, _data, _opts) do
    {:ok, %HTTPoison.Response{
      status_code: 200,
      body: %{
        "status" => "not_found"
      }
    }}
  end
end