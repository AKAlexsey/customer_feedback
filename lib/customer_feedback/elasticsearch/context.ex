defmodule CustomerFeedback.Elasticsearch.Context do
  @moduledoc """
  Contains functions to interact with Elasticsearch
  """

  alias CustomerFeedback.ElasticsearchCluster
  alias CustomerFeedback.CustomerInput.FeedbackDocument

  import CustomerFeedback.Utils, only: [changeset_error_to_string: 1]

  @feedback_documents_index "feedback_documents"
  @default_results_count 25

  def default_results_count, do: @default_results_count

  @doc """
  Validate document params and if they are valid - create document in Elasticsearch
  If params invalid or there are some error during saving the document - returns error
  """
  @spec create_feedback_document(map, (atom, map, binary -> any)) ::
          {:ok, binary} | {:error, binary}
  def create_feedback_document(params, post_document \\ &Elasticsearch.post_document/3) do
    with %{valid?: true, changes: changes} = valid_changeset <-
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
  @spec query_documents_for_customer(map, list) :: {:ok, list(map)}
  def query_documents_for_customer(customer_id, opts \\ []) do
    from = Keyword.get(opts, :offset, 0)
    size = Keyword.get(opts, :size, @default_results_count)
    query_documents(@feedback_documents_index, %{query: %{ term: %{customer_id: customer_id} }, from: from, size: size})
  end

  @spec query_feedback_documents(map) :: {:ok, list(map)}
  def query_feedback_documents(query \\ %{}) do
    query_documents(@feedback_documents_index, query)
  end

  @spec query_documents(binary, map) :: {:ok, list(map)} | {:error, binary}
  def query_documents(index, query) do
    ElasticsearchCluster
    |> Elasticsearch.post("/#{index}/_search", query)
  end
end
