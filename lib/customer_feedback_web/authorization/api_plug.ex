defmodule CustomerFeedbackWeb.Authorization.ApiPlug do
  import Plug.Conn

  @behaviour Plug

  @impl true
  def init(opts), do: opts

  @impl true
  def call(%{req_headers: request_headers_list} = conn, _opts) do
    with {:ok, {customer_id, customer_token}} <- fetch_customer_credentials(request_headers_list),
         :ok <- verify_customer_token(customer_id, customer_token) do
      conn
      |> put_session(:customer_id, "customer_id_#{:rand.uniform(3)}")
    else
      {:error, reason} ->
        conn
        |> send_resp(403, "#{reason}")
        |> halt()
    end
  end

  @spec fetch_customer_credentials(list) ::
          {:ok, {binary, binary}} | {:error, :no_authorization_header}
  defp fetch_customer_credentials(headers_list) do
    with {_, "Basic " <> encoded_credentials} <-
           headers_list
           |> Enum.find(fn
             {header, _} -> header == "Authorization" or header == "authorization"
           end),
         {:ok, credentials} <- Base.url_decode64(encoded_credentials),
         [customer_id, customer_token] <- String.split(credentials, ":") do
      {:ok, {customer_id, customer_token}}
    else
      _ ->
        {:error, :no_authorization_header}
    end
  end

  @permitted_customers ["customer_1", "customer_2", "customer_3", "customer_4", "customer_5"]
  @spec verify_customer_token(binary, binary) :: :ok | {:error, :customer_token_invalid}
  defp verify_customer_token(customer_id, customer_token) do
    if customer_id in @permitted_customers && customer_token == "secret_token" do
      :ok
    else
      {:error, :customer_token_invalid}
    end
  end
end
