defprotocol CustomerFeedback.ParseElasticQueryResult do
  @moduledoc """
  Allow to convert Elasticsearch query result to appropriate Ecto model
  """

  @spec convert(t, map) :: t
  def convert(empty_struct, params)
end

defimpl CustomerFeedback.ParseElasticQueryResult,
  for: CustomerFeedback.CustomerInput.FeedbackDocument do

  def convert(empty_struct, params) do
    %{
      "_id" => id,
      "_index" => "feedback_documents",
      "_score" => _,
      "_source" => %{
        "author" => author,
        "customer_id" => customer_id,
        "evaluation" => evaluation,
        "product_url" => product_url,
        "text" => text,
        "title" => title
      },
      "_type" => "_doc"
    } = params

    empty_struct
    |> Map.merge(%{
      id: id,
      title: title,
      author: author,
      text: text,
      evaluation: evaluation,
      product_url: product_url,
      customer_id: customer_id
    })
  end
end
