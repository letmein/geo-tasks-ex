defmodule Api.DriverRouter do
  use Api.Router, authorize_role: Db.Token.role_driver

  get "/tasks-nearby" do
    conn
    |> fetch_query_params()
    |> respond_with_tasks()
  end

  defp respond_with_tasks(conn) do
    with %{"lat" => lat_str, "long" => long_str} <- conn.query_params,
         {lat, _} <- Float.parse(lat_str),
         {long, _} <- Float.parse(long_str) do
      send_json(conn, 200, Db.nearby_tasks({lat, long}))
    else
      _ -> send_json(conn, 400, %{error: "Missing or invalid lat/long params"})
    end
  end
end
