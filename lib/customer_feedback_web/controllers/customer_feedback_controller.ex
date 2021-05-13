defmodule CustomerFeedbackWeb.CustomerFeedbackController do
  use CustomerFeedbackWeb, :controller

  import Plug.Conn

  plug :fetch_session
  plug CustomerFeedbackWeb.Authorization.ApiPlug

  alias CustomerFeedback.FeedbackGateway.RabbitProducer

  def create(conn, _params) do
    {:ok, body, conn} = Plug.Conn.read_body(conn)
    customer_id = Plug.Conn.get_session(conn, "customer_id")

    if binary_present(customer_id) && binary_present(body) do
      RabbitProducer.put_message("#{customer_id} #{body}")
      send_resp(conn, 200, "")
    else
      send_resp(conn, 422, "Request invalid")
    end
  end

  defp binary_present(value) when is_binary(value) do
    value != ""
  end
  defp binary_present(_), do: false
end
