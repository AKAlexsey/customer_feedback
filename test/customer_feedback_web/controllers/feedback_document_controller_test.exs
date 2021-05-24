# defmodule CustomerFeedbackWeb.FeedbackDocumentControllerTest do
#  use CustomerFeedbackWeb.ConnCase
#
#  alias CustomerFeedback.CustomerInput
#
#  @create_attrs %{author: "some author", customer_id: "some customer_id", evaluation: 42, product_url: "some product_url", text: "some text", title: "some title"}
#  @update_attrs %{author: "some updated author", customer_id: "some updated customer_id", evaluation: 43, product_url: "some updated product_url", text: "some updated text", title: "some updated title"}
#  @invalid_attrs %{author: nil, customer_id: nil, evaluation: nil, product_url: nil, text: nil, title: nil}
#
#  def fixture(:feedback_document) do
#    {:ok, feedback_document} = CustomerInput.create_feedback_document(@create_attrs)
#    feedback_document
#  end
#
#  describe "index" do
#    test "lists all feedback_documents", %{conn: conn} do
#      conn = get(conn, Routes.feedback_document_path(conn, :index))
#      assert html_response(conn, 200) =~ "Listing Feedback documents"
#    end
#  end
#
#  describe "new feedback_document" do
#    test "renders form", %{conn: conn} do
#      conn = get(conn, Routes.feedback_document_path(conn, :new))
#      assert html_response(conn, 200) =~ "New Feedback document"
#    end
#  end
#
#  describe "create feedback_document" do
#    test "redirects to show when data is valid", %{conn: conn} do
#      conn = post(conn, Routes.feedback_document_path(conn, :create), feedback_document: @create_attrs)
#
#      assert %{id: id} = redirected_params(conn)
#      assert redirected_to(conn) == Routes.feedback_document_path(conn, :show, id)
#
#      conn = get(conn, Routes.feedback_document_path(conn, :show, id))
#      assert html_response(conn, 200) =~ "Show Feedback document"
#    end
#
#    test "renders errors when data is invalid", %{conn: conn} do
#      conn = post(conn, Routes.feedback_document_path(conn, :create), feedback_document: @invalid_attrs)
#      assert html_response(conn, 200) =~ "New Feedback document"
#    end
#  end
#
#  describe "edit feedback_document" do
#    setup [:create_feedback_document]
#
#    test "renders form for editing chosen feedback_document", %{conn: conn, feedback_document: feedback_document} do
#      conn = get(conn, Routes.feedback_document_path(conn, :edit, feedback_document))
#      assert html_response(conn, 200) =~ "Edit Feedback document"
#    end
#  end
#
#  describe "update feedback_document" do
#    setup [:create_feedback_document]
#
#    test "redirects when data is valid", %{conn: conn, feedback_document: feedback_document} do
#      conn = put(conn, Routes.feedback_document_path(conn, :update, feedback_document), feedback_document: @update_attrs)
#      assert redirected_to(conn) == Routes.feedback_document_path(conn, :show, feedback_document)
#
#      conn = get(conn, Routes.feedback_document_path(conn, :show, feedback_document))
#      assert html_response(conn, 200) =~ "some updated author"
#    end
#
#    test "renders errors when data is invalid", %{conn: conn, feedback_document: feedback_document} do
#      conn = put(conn, Routes.feedback_document_path(conn, :update, feedback_document), feedback_document: @invalid_attrs)
#      assert html_response(conn, 200) =~ "Edit Feedback document"
#    end
#  end
#
#  describe "delete feedback_document" do
#    setup [:create_feedback_document]
#
#    test "deletes chosen feedback_document", %{conn: conn, feedback_document: feedback_document} do
#      conn = delete(conn, Routes.feedback_document_path(conn, :delete, feedback_document))
#      assert redirected_to(conn) == Routes.feedback_document_path(conn, :index)
#      assert_error_sent 404, fn ->
#        get(conn, Routes.feedback_document_path(conn, :show, feedback_document))
#      end
#    end
#  end
#
#  defp create_feedback_document(_) do
#    feedback_document = fixture(:feedback_document)
#    %{feedback_document: feedback_document}
#  end
# end
