defmodule ApiTest do
  use Db.RepoCase
  use Plug.Test

  describe "GET /api/drivers/nearby-tasks" do
    test "unauthorized request returns 401" do
      {status, _, _} =
        conn(:get, "/api/driver/tasks-nearby")
        |> Api.Endpoint.call(Api.Endpoint.init([]))
        |> sent_resp()

      assert status == 401
    end

    test "authorized request with missing query params returns 400" do
      {:ok, %{id: token_id, token: token}} = Db.create_token(Db.Token.role_driver)
      {:ok, %{id: user_id}} = Db.create_user(token_id)

      {status, _, _} =
        conn(:get, "/api/driver/tasks-nearby?lat=1")
        |> put_req_header("x-user-id", user_id)
        |> put_req_header("x-auth-token", token)
        |> Api.Endpoint.call(Api.Endpoint.init([]))
        |> sent_resp()

      assert status == 400
    end

    test "valid authorized request returns 200" do
      {:ok, %{id: token_id, token: token}} = Db.create_token(Db.Token.role_driver)
      {:ok, %{id: user_id}} = Db.create_user(token_id)


      {status, headers, _} =
        conn(:get, "/api/driver/tasks-nearby?lat=1&long=2")
        |> put_req_header("x-user-id", user_id)
        |> put_req_header("x-auth-token", token)
        |> Api.Endpoint.call(Api.Endpoint.init([]))
        |> sent_resp()

      assert status == 200
      assert {"content-type", "application/json; charset=utf-8"} in headers
    end
  end
end
