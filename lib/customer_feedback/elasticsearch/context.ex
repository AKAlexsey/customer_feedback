defmodule CustomerFeedback.Elasticsearch.Context do
  @moduledoc """
  Contains functions to interact with Elasticsearch
  """

  alias CustomerFeedback.ElasticsearchCluster
  alias CustomerFeedback.CustomerInput.FeedbackDocument

  import CustomerFeedback.Utils, only: [changeset_error_to_string: 1, prefix_mandatory_char: 2]

  @feedback_documents_index "feedback_documents"
  @default_results_count 25

  @type elastic_get_function_type :: (atom, binary, list -> Elasticsearch.response())
  @type elastic_post_function_type :: (atom, map, binary, list -> Elasticsearch.response())

  def default_results_count, do: @default_results_count

  @doc """
  Validate document params and if they are valid - create document in Elasticsearch
  If params invalid or there are some error during saving the document - returns error
  """
  @spec create_feedback_document(map, (atom, map, binary -> Elasticsearch.response())) ::
          {:ok, binary} | {:error, binary}
  def create_feedback_document(params, post_document \\ &Elasticsearch.post_document/3) do
    with %{valid?: true, changes: changes} <-
           FeedbackDocument.changeset(%FeedbackDocument{}, params),
         feedback_document <- Map.merge(%FeedbackDocument{}, changes),
         {:ok, %{"_index" => index}} <-
           post_document.(ElasticsearchCluster, feedback_document, @feedback_documents_index) do
      {:ok, index}
    else
      {:error, %Elasticsearch.Exception{message: message}} ->
        {:error, message}

      %{valid?: false} = error_changeset ->
        {:error, changeset_error_to_string(error_changeset)}
    end
  end

  @doc """
  Fetch documents for given customer_id.
  Second arguments - query options.

  Supported options:
  * `offset` - Offset of the fetched documents. Default is 0;
  * `size` - Amount of documents that must be returned. Default to 25.
  """
  @spec query_feedback_documents_for_customer(map, list, elastic_post_function_type) ::
          {:ok, list(map)}
  def query_feedback_documents_for_customer(
        customer_id,
        opts \\ [],
        elastic_post_function \\ &Elasticsearch.post/4
      ) do
    from = Keyword.get(opts, :offset, 0)
    size = Keyword.get(opts, :size, @default_results_count)

    query_documents(
      @feedback_documents_index,
      %{query: %{term: %{customer_id: customer_id}}, from: from, size: size},
      elastic_post_function
    )
  end

  @doc """
  Query feedback_documents using Query given as a map.
  For example:
  `query_feedback_documents(%{query: %{term: %{customer_id: customer_id}}, from: 20, size: 10})`

  or

  `query_feedback_documents(%{query: %{match_all: %{}}})`
  """
  @spec query_feedback_documents(map, elastic_post_function_type) :: {:ok, list(map)}
  def query_feedback_documents(query \\ %{}, elastic_post_function \\ &Elasticsearch.post/4) do
    query_documents(@feedback_documents_index, query, elastic_post_function)
  end

  @doc """
  Query feedback_document by given document _id.
  """
  @spec query_feedback_document(binary, elastic_get_function_type) :: {:ok, list(map)}
  def query_feedback_document(binary_id, elastic_get_function \\ &Elasticsearch.get/3) do
    "#{@feedback_documents_index}/_doc/#{binary_id}"
    |> prefix_mandatory_char("/")
    |> query_document(elastic_get_function)
  end

  @doc """
  Query feedback_document by given document _id.
  """
  @spec count_feedback_documents(elastic_get_function_type) :: Elasticsearch.response()
  def count_feedback_documents(elastic_get_function \\ &Elasticsearch.get/3) do
    count_index(@feedback_documents_index, elastic_get_function)
  end

  @spec count_index(binary, elastic_get_function_type) :: Elasticsearch.response()
  def count_index(index, elastic_get_function \\ &Elasticsearch.get/3) do
    query_document(prefix_mandatory_char("#{index}/_count", "/"), elastic_get_function)
  end

  @spec query_documents(binary, map, elastic_post_function_type) :: Elasticsearch.response()
  def query_documents(index, query, elastic_post_function \\ &Elasticsearch.post/4) do
    ElasticsearchCluster
    |> elastic_post_function.(prefix_mandatory_char("#{index}/_search", "/"), query, [])
  end

  @spec query_document(binary, elastic_get_function_type) :: Elasticsearch.response()
  def query_document(document_url, elastic_get_function \\ &Elasticsearch.get/3) do
    ElasticsearchCluster
    |> elastic_get_function.(prefix_mandatory_char(document_url, "/"), [])
  end
end
