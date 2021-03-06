defmodule Api.Endpoint do
  use Plug.Router

  plug Plug.Logger, log: :debug
  plug(:match)

  plug(Plug.Parsers,
    parsers: [:json],
    pass: ["application/json"],
    json_decoder: Poison
  )

  plug(:dispatch)

  forward("/api/driver", to: Api.DriverRouter)
  forward("/api/manager", to: Api.ManagerRouter)

  match _ do
    send_resp(conn, 404, "Page not found")
  end

  def child_spec(opts) do
    %{
      id: __MODULE__,
      start: {__MODULE__, :start_link, [opts]}
    }
  end

  def start_link(_opts), do: Plug.Cowboy.http(__MODULE__, [])
end
