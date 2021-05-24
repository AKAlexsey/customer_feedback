defmodule CustomerFeedback.Elasticsearch.ContextTest do
  use CustomerFeedback.DataCase

  alias CustomerFeedback.Elasticsearch.Context

  describe "#create_feedback_document" do
    setup do
      mocked_index = "feedback_documents-1620922372988908"

      {
        :ok,
        success_elastic_response: {
          :ok,
          %{
            "_id" => "-7LaaXkBO7I9u1E_ja4O",
            "_index" => mocked_index,
            "_primary_term" => 2,
            "_seq_no" => 1,
            "_shards" => %{
              "failed" => 0,
              "successful" => 1,
              "total" => 2
            },
            "_type" => "_doc",
            "_version" => 1,
            "result" => "created"
          }
        },
        mocked_index: mocked_index,
        fail_elastic_respones:
          {:error,
           %Elasticsearch.Exception{
             col: nil,
             line: nil,
             message: "Invalid index name [feedback_documents_SSSS], must be lowercase",
             query: nil,
             raw: %{
               "error" => %{
                 "index" => "feedback_documents_SSSS",
                 "index_uuid" => "_na_",
                 "reason" => "Invalid index name [feedback_documents_SSSS], must be lowercase",
                 "root_cause" => [
                   %{
                     "index" => "feedback_documents_SSSS",
                     "index_uuid" => "_na_",
                     "reason" =>
                       "Invalid index name [feedback_documents_SSSS], must be lowercase",
                     "type" => "invalid_index_name_exception"
                   }
                 ],
                 "type" => "invalid_index_name_exception"
               },
               "status" => 400
             },
             status: 400,
             type: "invalid_index_name_exception"
           }},
        customer_id: "1ab2344512"
      }
    end

    test "Return {:ok, binary} if params is valid", %{
      success_elastic_response: success_elastic_response,
      mocked_index: mocked_index,
      customer_id: customer_id
    } do
      evaluation = 8
      product_url = "https://localhost:4000/awesome_kettle/3"
      params = %{evaluation: evaluation, product_url: product_url, customer_id: customer_id}

      feedback_document_standard = %CustomerFeedback.CustomerInput.FeedbackDocument{
        author: nil,
        customer_id: customer_id,
        evaluation: evaluation,
        id: nil,
        product_url: product_url,
        text: nil,
        title: nil
      }

      post_document_mock = fn _, feedback_document, _ ->
        assert ^feedback_document_standard = feedback_document
        success_elastic_response
      end

      assert {:ok, ^mocked_index} = Context.create_feedback_document(params, post_document_mock)
    end

    test "Return {:error, binary} with explanation of the error if params is invalid", %{
      success_elastic_response: success_elastic_response,
      customer_id: customer_id
    } do
      post_document_mock = fn _, _, _ -> success_elastic_response end

      params = %{evaluation: 8, customer_id: "1ab2344512"}
      error_message = "product_url: can't be blank"

      assert {:error, ^error_message} =
               Context.create_feedback_document(params, post_document_mock)

      params = %{
        evaluation: -8,
        title: 3,
        product_url: "https://localhost:4000/awesome/kettle",
        customer_id: customer_id
      }

      error_message = "evaluation: must be greater than or equal to 0; title: is invalid"

      assert {:error, ^error_message} =
               Context.create_feedback_document(params, post_document_mock)

      params = %{
        evaluation: 11,
        text: "",
        product_url: "https://localhost:4000/awesome/kettle",
        author: 7
      }

      error_message =
        "author: is invalid; customer_id: can't be blank; evaluation: must be less than or equal to 10"

      assert {:error, ^error_message} =
               Context.create_feedback_document(params, post_document_mock)
    end

    test "Return {:error, binary} with explanation if elastic search returned an error", %{
      fail_elastic_respones: fail_elastic_respones,
      customer_id: customer_id
    } do
      params = %{
        evaluation: 8,
        product_url: "https://localhost:4000/awesome_kettle/3",
        customer_id: customer_id
      }

      post_document_mock = fn _, _, _ -> fail_elastic_respones end

      assert {:error, "Invalid index name [feedback_documents_SSSS], must be lowercase"} =
               Context.create_feedback_document(params, post_document_mock)
    end
  end
end
