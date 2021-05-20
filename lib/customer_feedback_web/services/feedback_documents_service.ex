defmodule CustomerFeedback.Services.FeedbackDocumentsService do
  @moduledoc """
  Perform pagination, filtering and ordering
  """

  alias CustomerFeedback.CustomerInput.FeedbackDocument
  alias CustomerFeedback.Elasticsearch.Context, as: ElasticsearchContext
  alias CustomerFeedback.ParseElasticQueryResult

  import CustomerFeedback.Utils, only: [safe_to_integer: 1]

  @default_per_page 25

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
    %{}
    |> put_size()
    |> put_from(params)
    |> put_filtration(params)
    |> put_ordering(params)
  end

  defp put_size(agg) do
    put_param(agg, :size, @default_per_page)
  end

  defp put_from(agg, params) do
    Map.get(params, "page", 0)
    |> safe_to_integer()
    |> (fn
          page when page in [0, 1] ->
            0

          integer_page ->
            (integer_page - 1) * @default_per_page
        end).()
    |> (fn from -> put_param(agg, :from, from) end).()
  end

  @permitted_filtration_params [
    "customer_id",
    "evaluation_greater",
    "evaluation_lover",
    "text_contains",
    "author",
    "title_contains"
  ]
  defp put_filtration(agg, params) do
    {filtration_params, _} = Map.split(params, @permitted_filtration_params)

    %{}
    |> put_customer_id_filtration(filtration_params)
    |> put_text_filtration(filtration_params)
    |> put_evaluation_filtration(filtration_params)
    |> (fn query_params ->
          if query_params == %{} do
            Map.put(agg, :query, %{match_all: %{}})
          else
            Map.put(agg, :query, query_params)
          end
        end).()
  end

  def put_customer_id_filtration(agg, %{"customer_id" => customer_id}) do
    agg
    |> Map.put(:term, %{customer_id: customer_id})
  end

  def put_customer_id_filtration(agg, _filtration_params), do: agg

  # TODO
  def put_text_filtration(agg, %{"text_contains" => text_contains}) do
    agg
    |> Map.put(:query_string, %{query: text_contains, default_field: "text"})
  end

  def put_text_filtration(agg, _filtration_params), do: agg

  def put_evaluation_filtration(agg, %{
        "evaluation_lover" => lover,
        "evaluation_greater" => greater
      }),
      do: Map.put(agg, :range, %{evaluation: %{gt: greater, lt: lover}})

  def put_evaluation_filtration(agg, %{"evaluation_lover" => lover}),
    do: Map.put(agg, :range, %{evaluation: %{lt: lover}})

  def put_evaluation_filtration(agg, %{"evaluation_greater" => greater}),
    do: Map.put(agg, :range, %{evaluation: %{gt: greater}})

  def put_evaluation_filtration(agg, _params), do: agg

  defp put_ordering(agg, _params) do
    # TODO implement
    agg
  end

  defp put_param(agg, name, func) do
    Map.put(agg, name, func)
  end

  defp resolve_result(
         {:ok,
          %{
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
