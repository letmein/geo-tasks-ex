defmodule Db do
  import Ecto.Query
  alias Db.{Repo, Token, Task, User}

  @moduledoc """
  Public API of the database.
  """

  @type geo_location :: {float, float}

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

  @spec nearby_tasks(geo_location) :: any()
  def nearby_tasks({lat, long}) do
    query =
      from t in Task,
        where: t.status == ^Task.status_new,
        select: %{
          id: t.id,
          description: t.description,
          distance: fragment("(POINT(?, ?) <@> POINT(?, ?)) AS distance", t.long1, t.lat1, ^long, ^lat)
        },
        order_by: [asc: fragment("distance")]

    query |> Repo.all
  end

  defp generate_token do
    :crypto.strong_rand_bytes(32) |> Base.url_encode64
  end
end
