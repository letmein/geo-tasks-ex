defmodule Db do
  import Ecto.Query
  alias Db.{Repo, Token, Task, User}

  @moduledoc """
  Public API of the database.
  """

  @type geo_location :: {float, float}

  def create_token(role) do
    %Token{token: generate_token(), role: role}
    |> Repo.insert
  end

  def create_user(token_id) do
    token = Token |> Repo.get(token_id)

    %User{token: token}
    |> Repo.insert
  end

  def authorized?(user_id, token_str, role)
    when is_binary(user_id) and is_binary(token_str) and is_binary(role) do
    case Ecto.UUID.cast(user_id) do
      {:ok, uuid} -> authorization_query(uuid, token_str, role) |> Repo.exists?
      _ -> false
    end
  end

  def authorized?(_, _, _), do: false

  @spec create_task(geo_location, geo_location, String.t()) :: {:ok, %Task{}}
  def create_task({lat1, long1}, {lat2, long2}, description \\ "") do
    %Task{
      status: Task.status_new,
      description: description,
      lat1: lat1,
      long1: long1,
      lat2: lat2,
      long2: long2
    }
    |> Repo.insert
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

  defp generate_token do
    :crypto.strong_rand_bytes(32) |> Base.url_encode64
  end

  defp authorization_query(uuid, token_str, role) do
    from u in User,
      join: t in assoc(u, :token),
      where: u.id == ^uuid and t.token == ^token_str and t.role == ^role
  end
end
