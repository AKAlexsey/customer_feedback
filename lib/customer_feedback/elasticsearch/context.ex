defmodule CustomerFeedback.Elasticsearch.Context do
  @moduledoc """
  Contains functions to interact with Elasticsearch
  """

  alias CustomerFeedback.ElasticsearchCluster
  alias CustomerFeedback.CustomerInput.FeedbackDocument

  import CustomerFeedback.Utils, only: [changeset_error_to_string: 1]

  @feedback_documents_index "feedback_documents"

  @doc """
  Validate document params and if they are valid - create document in Elasticsearch
  If params invalid or there are some error during saving the document - returns error
  """
  @spec create_feedback_document(map, (atom, map, binary -> any)) :: {:ok, binary} | {:error, binary}
  def create_feedback_document(params, post_document \\ &Elasticsearch.post_document/3) do
    with %{valid?: true, changes: changes} = valid_changeset <- FeedbackDocument.changeset(%FeedbackDocument{}, params),
          feedback_document <- Map.merge(%FeedbackDocument{}, changes),
         {:ok, %{"_index" => index}} <- post_document.(ElasticsearchCluster, feedback_document, @feedback_documents_index) do
      {:ok, index}
    else
      {:error, %Elasticsearch.Exception{message: message}} ->
        {:error, message}
      %{valid?: false} = error_changeset ->
        {:error, changeset_error_to_string(error_changeset)}
    end
  end
end