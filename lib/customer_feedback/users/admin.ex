defmodule CustomerFeedback.Users.Admin do
  use Ecto.Schema
  import Ecto.Changeset

  @cast_fields [:name]
  @required_fields [:name]

  schema "admins" do
    field :name, :string

    timestamps()
  end

  @doc false
  def changeset(admin, attrs) do
    admin
    |> cast(attrs, @cast_fields)
    |> validate_required(@required_fields)
  end
end
