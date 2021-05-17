defmodule CustomerFeedbackWeb.FeedbackDocumentController do
  use CustomerFeedbackWeb, :controller

  alias CustomerFeedback.CustomerInput
  alias CustomerFeedback.CustomerInput.FeedbackDocument

  alias CustomerFeedback.Services.FeedbackDocumentsService

  def index(conn, pagination_params) do
    {:ok, {feedback_documents, pagination}} = FeedbackDocumentsService.index(pagination_params)

    render(conn, "index.html", feedback_documents: feedback_documents, pagination: pagination)
  end

  def new(conn, _params) do
    changeset = CustomerInput.change_feedback_document(%FeedbackDocument{})
    render(conn, "new.html", changeset: changeset)
  end

  def create(conn, %{"feedback_document" => feedback_document_params}) do
    case CustomerInput.create_feedback_document(feedback_document_params) do
      {:ok, feedback_document} ->
        conn
        |> put_flash(:info, "Feedback document created successfully.")
        |> redirect(to: Routes.feedback_document_path(conn, :show, feedback_document))

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "new.html", changeset: changeset)
    end
  end

  def show(conn, %{"id" => id}) do
    {:ok, feedback_document} = FeedbackDocumentsService.show(id)

    render(conn, "show.html", feedback_document: feedback_document)
  end

  def edit(conn, %{"id" => id}) do
    feedback_document = CustomerInput.get_feedback_document!(id)
    changeset = CustomerInput.change_feedback_document(feedback_document)
    render(conn, "edit.html", feedback_document: feedback_document, changeset: changeset)
  end

  def update(conn, %{"id" => id, "feedback_document" => feedback_document_params}) do
    feedback_document = CustomerInput.get_feedback_document!(id)

    case CustomerInput.update_feedback_document(feedback_document, feedback_document_params) do
      {:ok, feedback_document} ->
        conn
        |> put_flash(:info, "Feedback document updated successfully.")
        |> redirect(to: Routes.feedback_document_path(conn, :show, feedback_document))

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "edit.html", feedback_document: feedback_document, changeset: changeset)
    end
  end

  def delete(conn, %{"id" => id}) do
    feedback_document = CustomerInput.get_feedback_document!(id)
    {:ok, _feedback_document} = CustomerInput.delete_feedback_document(feedback_document)

    conn
    |> put_flash(:info, "Feedback document deleted successfully.")
    |> redirect(to: Routes.feedback_document_path(conn, :index))
  end
end
