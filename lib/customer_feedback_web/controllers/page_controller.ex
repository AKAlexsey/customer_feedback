defmodule CustomerFeedbackWeb.PageController do
  use CustomerFeedbackWeb, :controller

  def index(conn, _params) do
    render(conn, "index.html")
  end
end
