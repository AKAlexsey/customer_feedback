defmodule CustomerFeedbackWeb.FeedbackDocumentController do
  use CustomerFeedbackWeb, :controller

  alias CustomerFeedback.Services.FeedbackDocumentsService

  def index(conn, pagination_params) do
    {:ok, {feedback_documents, pagination}} = FeedbackDocumentsService.index(pagination_params)

    render(conn, "index.html", feedback_documents: feedback_documents, pagination: pagination)
  end

  def show(conn, %{"id" => id}) do
    FeedbackDocumentsService.show(id)
    |> case do
         {:ok, feedback_document} ->
           render(conn, "show.html", feedback_document: feedback_document)
         {:error, reason} ->
           conn
           |> put_flash(:error, reason)
           |> redirect(to: Routes.feedback_document_path(conn, :index))
       end
  end
end
