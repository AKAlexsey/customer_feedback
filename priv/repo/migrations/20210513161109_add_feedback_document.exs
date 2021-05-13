defmodule CustomerFeedback.Repo.Migrations.AddFeedbackDocument do
  use Ecto.Migration

  def change do
    create table(:feedback_documents) do
      add :title, :string
      add :author, :string
      add :text, :text
      add :product_url, :string
      add :evaluation, :integer

      timestamps()
    end
  end
end
