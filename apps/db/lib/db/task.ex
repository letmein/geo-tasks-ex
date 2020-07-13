defmodule Db.Task do
  use Ecto.Schema
  import Ecto.Changeset

  @derive {Poison.Encoder, only: [:id, :description, :lat1, :long1, :lat2, :long2, :status]}

  def status_new, do: "new"
  def status_assigned, do: "assigned"
  def status_done, do: "done"

  schema "tasks" do
    belongs_to :driver, Db.User, type: :binary_id
    field :description, :string
    field :status, :string
    field :lat1, :float
    field :long1, :float
    field :lat2, :float
    field :long2, :float

    timestamps()
  end

  def complete(task) do
    task
    |> cast(%{status: status_done()}, [:status])
  end

  def assign(task, user_id) do
    task
    |> cast(%{driver_id: user_id, status: status_assigned()}, [:driver_id, :status])
  end

  def new(params \\ %{}) do
    %Db.Task{status: status_new()}
    |> cast(params, [:description, :lat1, :long1, :lat2, :long2])
    |> validate_required([:lat1, :long1, :lat2, :long2])
  end
end
