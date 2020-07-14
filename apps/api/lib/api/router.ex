defmodule Api.Router do
  defmacro __using__(authorize_role: role_name) do
    quote do
      use Plug.Router

      plug(:match)

      plug(Plug.Parsers, parsers: [:json], json_decoder: Poison, pass: ["application/json"])
      plug(Api.Authorize, role: unquote(role_name))

      plug(:dispatch)

      def send_json(conn, status, body) do
        conn
        |> put_resp_content_type("application/json")
        |> send_resp(status, Poison.encode!(body))
      end
    end
  end
end
