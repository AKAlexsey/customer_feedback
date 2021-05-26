defmodule CustomerFeedback.CustomerInput.FeedbackDocument do
  @moduledoc false

  use Ecto.Schema
  import Ecto.Changeset
  import CustomerFeedback.Utils, only: [changeset_error_to_string: 1]

  @cast_fields [:title, :author, :text, :evaluation, :product_url, :customer_id]
  @required_fields [:evaluation, :product_url, :customer_id]

  @minimum_evaluation 0
  @maximum_evaluation 10

  @type t :: %__MODULE__{}

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

  @doc """
  """
  @spec validate(map) :: {:ok, t} | {:error, binary}
  def validate(params) do
    with %{valid?: true, changes: changes} <- changeset(%__MODULE__{}, params),
         feedback_document <- Map.merge(%__MODULE__{}, changes) do
      {:ok, feedback_document}
    else
      %{valid?: false} = error_changeset ->
        {:error, changeset_error_to_string(error_changeset)}
    end
  end
end
