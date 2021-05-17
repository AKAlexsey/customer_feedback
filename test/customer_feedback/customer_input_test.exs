#defmodule CustomerFeedback.CustomerInputTest do
#  use CustomerFeedback.DataCase
#
#  alias CustomerFeedback.CustomerInput
#
#  describe "feedback_documents" do
#    alias CustomerFeedback.CustomerInput.FeedbackDocument
#
#    @valid_attrs %{author: "some author", customer_id: "some customer_id", evaluation: 42, product_url: "some product_url", text: "some text", title: "some title"}
#    @update_attrs %{author: "some updated author", customer_id: "some updated customer_id", evaluation: 43, product_url: "some updated product_url", text: "some updated text", title: "some updated title"}
#    @invalid_attrs %{author: nil, customer_id: nil, evaluation: nil, product_url: nil, text: nil, title: nil}
#
#    def feedback_document_fixture(attrs \\ %{}) do
#      {:ok, feedback_document} =
#        attrs
#        |> Enum.into(@valid_attrs)
#        |> CustomerInput.create_feedback_document()
#
#      feedback_document
#    end
#
#    test "list_feedback_docments/0 returns all feedback_documents" do
#      feedback_document = feedback_document_fixture()
#      assert CustomerInput.list_feedback_docments() == [feedback_document]
#    end
#
#    test "get_feedback_document!/1 returns the feedback_document with given id" do
#      feedback_document = feedback_document_fixture()
#      assert CustomerInput.get_feedback_document!(feedback_document.id) == feedback_document
#    end
#
#    test "create_feedback_document/1 with valid data creates a feedback_document" do
#      assert {:ok, %FeedbackDocument{} = feedback_document} = CustomerInput.create_feedback_document(@valid_attrs)
#      assert feedback_document.author == "some author"
#      assert feedback_document.customer_id == "some customer_id"
#      assert feedback_document.evaluation == 42
#      assert feedback_document.product_url == "some product_url"
#      assert feedback_document.text == "some text"
#      assert feedback_document.title == "some title"
#    end
#
#    test "create_feedback_document/1 with invalid data returns error changeset" do
#      assert {:error, %Ecto.Changeset{}} = CustomerInput.create_feedback_document(@invalid_attrs)
#    end
#
#    test "update_feedback_document/2 with valid data updates the feedback_document" do
#      feedback_document = feedback_document_fixture()
#      assert {:ok, %FeedbackDocument{} = feedback_document} = CustomerInput.update_feedback_document(feedback_document, @update_attrs)
#      assert feedback_document.author == "some updated author"
#      assert feedback_document.customer_id == "some updated customer_id"
#      assert feedback_document.evaluation == 43
#      assert feedback_document.product_url == "some updated product_url"
#      assert feedback_document.text == "some updated text"
#      assert feedback_document.title == "some updated title"
#    end
#
#    test "update_feedback_document/2 with invalid data returns error changeset" do
#      feedback_document = feedback_document_fixture()
#      assert {:error, %Ecto.Changeset{}} = CustomerInput.update_feedback_document(feedback_document, @invalid_attrs)
#      assert feedback_document == CustomerInput.get_feedback_document!(feedback_document.id)
#    end
#
#    test "delete_feedback_document/1 deletes the feedback_document" do
#      feedback_document = feedback_document_fixture()
#      assert {:ok, %FeedbackDocument{}} = CustomerInput.delete_feedback_document(feedback_document)
#      assert_raise Ecto.NoResultsError, fn -> CustomerInput.get_feedback_document!(feedback_document.id) end
#    end
#
#    test "change_feedback_document/1 returns a feedback_document changeset" do
#      feedback_document = feedback_document_fixture()
#      assert %Ecto.Changeset{} = CustomerInput.change_feedback_document(feedback_document)
#    end
#  end
#end
