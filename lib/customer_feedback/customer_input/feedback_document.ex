defmodule CustomerFeedback.CustomerInput.FeedbackDocument do
  @moduledoc false

  # First document
  #  %{
  #    "_id" => "MOaBZnkBtFt1Lk6-NbCY",
  #    "_index" => "feedback_documents-1620922372988908",
  #    "_primary_term" => 1,
  #    "_seq_no" => 0,
  #    "_shards" => %{"failed" => 0, "successful" => 1, "total" => 2},
  #    "_type" => "_doc",
  #    "_version" => 1,
  #    "result" => "created"
  #  }}

  use Ecto.Schema
  import Ecto.Changeset

  @cast_fields [:title, :author, :text, :evaluation, :product_url, :customer_id]
  @required_fields [:evaluation, :product_url, :customer_id]

  @minimum_evaluation 0
  @maximum_evaluation 10

  schema "feedback_documents" do
    field :title, :string
    field :author, :string
    field :text, :string
    field :product_url, :string
    field :evaluation, :integer
    field :customer_id, :string
  end

  @doc false
  def changeset(feedback_document, attrs) do
    feedback_document
    |> cast(attrs, @cast_fields)
    |> validate_required(@required_fields)
    |> validate_number(:evaluation,
      greater_than_or_equal_to: @minimum_evaluation,
      less_than_or_equal_to: @maximum_evaluation
    )
  end
end
