defmodule CustomerFeedbackWeb.CustomerFeedbackController do
  use CustomerFeedbackWeb, :controller

  import Plug.Conn

  plug :fetch_session
  plug CustomerFeedbackWeb.Authorization.ApiPlug

  alias CustomerFeedback.FeedbackGateway.ConverterBroadway

  def create(conn, feedback_params) do
    customer_id = Plug.Conn.get_session(conn, "customer_id")

    if map_size(feedback_params) > 0 do
      ConverterBroadway.push_element(customer_id, feedback_params)

      send_resp(conn, 200, "")
    else
      send_resp(conn, 422, "Request invalid")
    end
  end
end
