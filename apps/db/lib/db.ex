defmodule Db do
  import Ecto.Query
  alias Db.{Repo, Token, Task, User}

  @moduledoc """
  Public API of the database.
  """

  @type geo_location :: {float, float}

  @spec role_manager() :: String.t()
  def role_manager, do: "manager"

  @spec role_driver() :: String.t()
  def role_driver, do: "driver"

  @spec create_token(String.t()) :: {:error, map} | {:ok, %Token{}}
  def create_token(role) do
    %Token{token: generate_token(), role: role}
    |> Repo.insert
  end

  @spec create_user(integer) :: {:error, map} | {:ok, %User{}}
  def create_user(token_id) do
    token = Token |> Repo.get(token_id)

    %User{token: token}
    |> Repo.insert
  end

  @spec authorized?(String.t(), String.t(), String.t()) :: boolean
  def authorized?(user_id, token_str, role)
    when is_binary(user_id) and is_binary(token_str) and is_binary(role) do
    case Ecto.UUID.cast(user_id) do
      {:ok, uuid} -> authorization_query(uuid, token_str, role) |> Repo.exists?
      _ -> false
    end
  end

  def authorized?(_, _, _), do: false

  @spec assign_task(String.t(), String.t()) :: {:ok, %Task{}} | {:error, map}
  def assign_task(task_id, user_id) do
    case get_unassigned_task(task_id) do
      nil -> {:error, %{task_id: "Task not found"}}
      task -> assign_task_to_driver(task, user_id)
    end
  end

  @spec complete_task(String.t(), String.t()) :: {:ok, %Task{}} | {:error, map}
  def complete_task(task_id, user_id) do
    case get_assigned_task(user_id, task_id) do
      nil -> {:error, %{task_id: "Task not found"}}
      task -> complete_assigned_task(task)
    end
  end

  @spec create_task(geo_location, geo_location, String.t()) :: {:ok, %Task{}} | {:error, map}
  def create_task({lat1, long1}, {lat2, long2}, description \\ "") do
    Task.new(%{
      description: description,
      lat1: lat1,
      long1: long1,
      lat2: lat2,
      long2: long2
    })
    |> Repo.insert()
    |> format_result()
  end

  @spec nearby_tasks(geo_location, integer()) :: any()
  def nearby_tasks({lat, long}, limit \\ 10) do
    query =
      from t in Task,
        where: t.status == ^Task.status_new,
        select: %{
          id: t.id,
          description: t.description,
          distance: fragment("(POINT(?, ?) <@> POINT(?, ?)) AS distance", t.long1, t.lat1, ^long, ^lat)
        },
        order_by: [asc: fragment("distance")],
        limit: ^limit

    Repo.all(query)
  end

  defp complete_assigned_task(task) do
    task
    |> Task.complete()
    |> Repo.update()
    |> format_result()
  end

  defp assign_task_to_driver(task, user_id) do
    task
    |> Task.assign(user_id)
    |> Repo.update()
    |> format_result()
  end

  defp generate_token do
    :crypto.strong_rand_bytes(32) |> Base.url_encode64
  end

  defp authorization_query(uuid, token_str, role) do
    from u in User,
      join: t in assoc(u, :token),
      where: u.id == ^uuid and t.token == ^token_str and t.role == ^role
  end

  defp get_unassigned_task(task_id) do
    query =
      from t in Task,
        where: t.status == ^Task.status_new and t.id == ^task_id

    Repo.one(query)
  end

  defp get_assigned_task(user_id, task_id) do
    query =
      from t in Task,
        where: t.status == ^Task.status_assigned and t.id == ^task_id and t.driver_id == ^user_id

    Repo.one(query)
  end

  defp format_result({:error, changeset}) do
    messages = for {field, {message, _}} <- changeset.errors, into: %{}, do: {field, message}

    {:error, messages}
  end

  defp format_result({:ok, _} = result), do: result
end
