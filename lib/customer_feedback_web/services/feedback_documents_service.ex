defmodule CustomerFeedback.Services.FeedbackDocumentsService do
  @moduledoc """
  Perform pagination, filtering and ordering
  """

  alias CustomerFeedback.CustomerInput.FeedbackDocument
  alias CustomerFeedback.Elasticsearch.Context, as: ElasticsearchContext
  alias CustomerFeedback.ParseElasticQueryResult

  import CustomerFeedback.Utils, only: [safe_to_integer: 1]

  @default_per_page 5

  @doc """
  Perform pagination, filtering and ordering for all feedback documents
  Fetch documents by given params. Return `{:ok, list(map)}`
  """
  @spec index(map) :: {:ok, {list(FeedbackDocument.t()), map}} | {:error, {binary, map}}
  def index(params) do
    params
    |> params_to_elastic_query()
    |> ElasticsearchContext.query_feedback_documents()
    |> resolve_result(params)
  end

  @spec params_to_elastic_query(map) :: map
  defp params_to_elastic_query(params) do
    page = Map.get(params, "page", "0")
    from = safe_to_integer(page) * @default_per_page

    %{query: %{match_all: %{}}, from: from, size: @default_per_page}
  end

  defp resolve_result(
         {:ok, %{
           "hits" => %{
             "hits" => documents,
             "total" => %{
               "value" => total
             }
           }
         }},
         params
       ) do
    {
      :ok,
      {
        Enum.map(documents, fn document_params ->
          ParseElasticQueryResult.convert(%FeedbackDocument{}, document_params)
        end),
        Map.put(params, "total_amount", total)
      }
    }
  end

  defp resolve_result({:error, %Elasticsearch.Exception{message: message}}, params) do
    {:error, {message, params}}
  end

  @doc """
  Fetch document by id.
  If document exists - return {:ok, %CustomerFeedback.CustomerInput.FeedbackDocument{}}
  If document does not exist - return {:error, "Document with ID <doc id> not found"}
  """
  @spec show(binary) :: {:ok, FeedbackDocument.t()} | {:error, binary}
  def show(document_id) do
    document_id
    |> ElasticsearchContext.query_feedback_document()
    |> case do
         {:ok, document_params} ->
           {:ok, ParseElasticQueryResult.convert(%FeedbackDocument{}, document_params)}
         {:error, %Elasticsearch.Exception{type: "document_not_found"}} ->
           {:error, "Document with ID #{document_id} not found"}
         {:error, %Elasticsearch.Exception{type: unexpected_error}} ->
           {:error, "Error fetching document: #{unexpected_error}"}
       end
  end
end
