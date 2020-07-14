defmodule ApiTest do
  use Db.RepoCase
  use Plug.Test

  def get_response(conn) do
    conn
    |> Api.Endpoint.call(Api.Endpoint.init([]))
    |> sent_resp()
  end

  def authenticate_driver(conn) do
    {user_id, token} = create_user_with_token(Db.role_driver)
    add_auth_headers(conn, user_id, token)
  end

  def authenticate_manager(conn) do
    {user_id, token} = create_user_with_token(Db.role_manager)
    add_auth_headers(conn, user_id, token)
  end

  def add_auth_headers(conn, user_id, token) do
    conn
    |> put_req_header("x-user-id", user_id)
    |> put_req_header("x-auth-token", token)
  end

  def create_user_with_token(role) do
    with {:ok, %{id: token_id, token: token}} <- Db.create_token(role),
         {:ok, %{id: user_id}} <- Db.create_user(token_id) do
      {user_id, token}
    else
      _ -> :error
    end
  end

  describe "GET /api/driver/tasks-nearby" do
    test "return error when no auth headers provided" do
      {status, _, _} =
        conn(:get, "/api/driver/tasks-nearby")
        |> get_response()

      assert status == 401
    end

    test "return error when lat/long params are missing" do
      {status, _, _} =
        conn(:get, "/api/driver/tasks-nearby?lat=1")
        |> authenticate_driver()
        |> get_response()


      assert status == 400
    end

    test "return success to authorized driver" do
      {status, headers, _} =
        conn(:get, "/api/driver/tasks-nearby?lat=1&long=2")
        |> authenticate_driver()
        |> get_response()

      assert status == 200
      assert {"content-type", "application/json; charset=utf-8"} in headers
    end
  end

  describe "POST /api/manager/tasks" do
    test "return error when no auth headers provided" do
      {status, _, _} =
        conn(:post, "/api/manager/tasks")
        |> get_response()

      assert status == 401
    end

    test "driver can not create tasks" do
      {status, _, _} =
        conn(:post, "/api/manager/tasks")
        |> authenticate_driver()
        |> get_response()

      assert status == 401
    end

    test "manager submits invalid payload" do
      {status, headers, body} =
        conn(:post, "/api/manager/tasks", ~s({"lat1": 1, "long1": 2, "lat2": 3}))
        |> put_req_header("content-type", "application/json")
        |> authenticate_manager()
        |> get_response()

      assert status == 422
      assert {"content-type", "application/json; charset=utf-8"} in headers
      assert body == ~s({"long2":"can't be blank"})
    end

    test "manager successfully creates a task" do
      {status, headers, body} =
        conn(:post, "/api/manager/tasks", ~s({"lat1": 1, "long1": 2, "lat2": 3, "long2": 4}))
        |> put_req_header("content-type", "application/json")
        |> authenticate_manager()
        |> get_response()

      assert status == 201
      assert {"content-type", "application/json; charset=utf-8"} in headers
      assert %{
        "lat1" => 1.0,
        "long1" => 2.0,
        "lat2" => 3.0,
        "long2" => 4.0,
        "status" => "new"
      } = Poison.decode!(body)
    end
  end

  describe "POST /api/driver/task/:task_id/assign" do
    test "driver assigns task" do
      {:ok, task} = Db.create_task({1, 1}, {2, 2})

      {status, _, body} =
        conn(:post, "/api/driver/task/#{task.id}/assign")
        |> authenticate_driver()
        |> get_response()

      assert status == 200
      assert %{"status" => "assigned"} = Poison.decode!(body)
    end
  end

  describe "POST /api/driver/task/:task_id/complete" do
    test "driver completes task" do
      {user_id, token} = create_user_with_token(Db.role_driver)
      {:ok, task} = Db.create_task({1, 1}, {2, 2})
      {:ok, _} = Db.assign_task(task.id, user_id)

      {status, _, body} =
        conn(:post, "/api/driver/task/#{task.id}/complete")
        |> add_auth_headers(user_id, token)
        |> get_response()

      assert status == 200
      assert %{"status" => "done"} = Poison.decode!(body)
    end
  end
end
