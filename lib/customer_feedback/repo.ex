defmodule CustomerFeedback.Repo do
  use Ecto.Repo,
    otp_app: :customer_feedback,
    adapter: Ecto.Adapters.Postgres
end
