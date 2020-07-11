defmodule Api.Authorize do
  import Plug.Conn

  def init(opts), do: opts

  def call(conn, role: role) do
    with [user_id | _] <- get_req_header(conn, "x-user-id"),
         [token | _] <- get_req_header(conn, "x-auth-token"),
         true <- Db.authorized?(user_id, token, role) do
      assign(conn, :user_id, user_id)
    else
      _ ->
        conn
        |> send_resp(401, "Unauthorized")
        |> halt
    end
  end
end
