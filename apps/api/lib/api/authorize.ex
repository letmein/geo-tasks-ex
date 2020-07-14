defmodule Api.Authorize do
  import Plug.Conn

  @spec init(any) :: any
  def init(opts), do: opts

  @spec call(Plug.Conn.t(), [{:role, String.t()}]) :: Plug.Conn.t()
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
