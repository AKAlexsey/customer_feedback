defmodule CustomerFeedback.Elasticsearch.Context do
  @moduledoc """
  Contains functions to interact with Elasticsearch
  """

  alias CustomerFeedback.ElasticsearchCluster
  alias CustomerFeedback.CustomerInput.FeedbackDocument

  import CustomerFeedback.Utils, only: [prefix_mandatory_char: 2]

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
    with {:ok, feedback_document} <- FeedbackDocument.validate(params),
         {:ok, %{"_index" => index}} <-
           post_document.(ElasticsearchCluster, feedback_document, @feedback_documents_index) do
      {:ok, index}
    else
      {:error, %Elasticsearch.Exception{message: message}} ->
        {:error, message}

      {:error, reason} when is_binary(reason) ->
        {:error, reason}
    end
  end

  @doc """
  Validate document params and if they are valid - create document in Elasticsearch
  If params invalid or there are some error during saving the document - returns error
  """
  @spec create_feedback_documents_in_batch(
          list(map),
          (atom, map, binary, list -> Elasticsearch.response())
        ) ::
          {:ok, binary} | {:error, binary}
  def create_feedback_documents_in_batch(
        feedback_documents_params,
        post_function \\ &Elasticsearch.post/4
      ) do
    with {success, _failed} when success != [] <- validate_all_docs(feedback_documents_params),
         compiled_batch <- compile_documents_batch(success),
         bulk_url <- prefix_mandatory_char("#{@feedback_documents_index}/_bulk", "/"),
         {:ok, %{}} <-
           post_function.(ElasticsearchCluster, bulk_url, compiled_batch, []) do
      {:ok, "OK"}
    else
      {:error, %Elasticsearch.Exception{message: message}} ->
        {:error, message}

      {[], failed} ->
        {:error, "Document validations list:\n#{Enum.join(failed, "\n")}"}
    end
  end

  defp validate_all_docs(feedback_documents_params) do
    feedback_documents_params
    |> Enum.reduce({[], []}, fn params, {success, failed} ->
      FeedbackDocument.validate(params)
      |> case do
        {:ok, feedback_document} ->
          {[feedback_document] ++ success, failed}

        {:error, reason} ->
          {success, [reason] ++ failed}
      end
    end)
  end

  defp compile_documents_batch(feedback_documents) do
    feedback_documents
    |> Enum.map(fn feedback_document ->
      Elasticsearch.Index.Bulk.encode!(
        ElasticsearchCluster,
        feedback_document,
        @feedback_documents_index
      )
    end)
    |> Enum.join("")
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
