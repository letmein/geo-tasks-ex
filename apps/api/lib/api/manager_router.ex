defmodule Api.ManagerRouter do
  use Api.Router, authorize_role: Db.Token.role_manager

  post "/tasks" do
    case create_task(conn.body_params) do
      {:ok, task} -> send_json(conn, 201, task)
      {:error, changeset} -> send_json(conn, 422, format_errors(changeset))
    end
  end

  defp create_task(json) do
    Db.create_task({json["lat1"], json["long1"]}, {json["lat2"], json["long2"]}, json["description"])
  end

  defp format_errors(changeset) do
    for {field, {message, _}} <- changeset.errors, into: %{}, do: {field, message}
  end
end
