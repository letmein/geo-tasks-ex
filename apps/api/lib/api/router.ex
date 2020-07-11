defmodule Api.Router do
  defmacro __using__(authorize_role: role_name) do
    quote do
      use Plug.Router

      plug(Api.Authorize, role: unquote(role_name))
      plug(:match)
      plug(:dispatch)

      def send_json(conn, status, body) do
        conn
        |> put_resp_content_type("application/json")
        |> send_resp(status, Poison.encode!(body))
      end
    end
  end
end