defmodule CustomerFeedback.Repo.Migrations.AddCustomerIdToFeedbackDocuments do
  use Ecto.Migration

  def change do
    alter table(:feedback_documents) do
      add :customer_id, :string
    end
  end
end
