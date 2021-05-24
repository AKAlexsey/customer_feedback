defimpl Elasticsearch.Document, for: CustomerFeedback.CustomerInput.FeedbackDocument do
  def id(feedback_document), do: feedback_document.id
  def routing(_), do: false

  def encode(feedback_document) do
    %{
      title: feedback_document.title,
      author: feedback_document.author,
      text: feedback_document.text,
      evaluation: feedback_document.evaluation,
      product_url: feedback_document.product_url,
      customer_id: feedback_document.customer_id
    }
  end
end
