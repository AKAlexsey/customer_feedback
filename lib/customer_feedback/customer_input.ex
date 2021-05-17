#defmodule CustomerFeedback.CustomerInput do
#  @moduledoc """
#  The CustomerInput context.
#  """
#
#  import Ecto.Query, warn: false
#  alias CustomerFeedback.Repo
#
#  alias CustomerFeedback.CustomerInput.FeedbackDocument
#
#  @doc """
#  Returns the list of feedback_documents.
#
#  ## Examples
#
#      iex> list_feedback_docments()
#      [%FeedbackDocument{}, ...]
#
#  """
#  def list_feedback_docments do
#    Repo.all(FeedbackDocument)
#  end
#
#  @doc """
#  Gets a single feedback_document.
#
#  Raises `Ecto.NoResultsError` if the Feedback document does not exist.
#
#  ## Examples
#
#      iex> get_feedback_document!(123)
#      %FeedbackDocument{}
#
#      iex> get_feedback_document!(456)
#      ** (Ecto.NoResultsError)
#
#  """
#  def get_feedback_document!(id), do: Repo.get!(FeedbackDocument, id)
#
#  @doc """
#  Creates a feedback_document.
#
#  ## Examples
#
#      iex> create_feedback_document(%{field: value})
#      {:ok, %FeedbackDocument{}}
#
#      iex> create_feedback_document(%{field: bad_value})
#      {:error, %Ecto.Changeset{}}
#
#  """
#  def create_feedback_document(attrs \\ %{}) do
#    %FeedbackDocument{}
#    |> FeedbackDocument.changeset(attrs)
#    |> Repo.insert()
#  end
#
#  @doc """
#  Updates a feedback_document.
#
#  ## Examples
#
#      iex> update_feedback_document(feedback_document, %{field: new_value})
#      {:ok, %FeedbackDocument{}}
#
#      iex> update_feedback_document(feedback_document, %{field: bad_value})
#      {:error, %Ecto.Changeset{}}
#
#  """
#  def update_feedback_document(%FeedbackDocument{} = feedback_document, attrs) do
#    feedback_document
#    |> FeedbackDocument.changeset(attrs)
#    |> Repo.update()
#  end
#
#  @doc """
#  Deletes a feedback_document.
#
#  ## Examples
#
#      iex> delete_feedback_document(feedback_document)
#      {:ok, %FeedbackDocument{}}
#
#      iex> delete_feedback_document(feedback_document)
#      {:error, %Ecto.Changeset{}}
#
#  """
#  def delete_feedback_document(%FeedbackDocument{} = feedback_document) do
#    Repo.delete(feedback_document)
#  end
#
#  @doc """
#  Returns an `%Ecto.Changeset{}` for tracking feedback_document changes.
#
#  ## Examples
#
#      iex> change_feedback_document(feedback_document)
#      %Ecto.Changeset{data: %FeedbackDocument{}}
#
#  """
#  def change_feedback_document(%FeedbackDocument{} = feedback_document, attrs \\ %{}) do
#    FeedbackDocument.changeset(feedback_document, attrs)
#  end
#end
