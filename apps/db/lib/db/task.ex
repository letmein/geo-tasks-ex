defmodule Db.Task do
  use Ecto.Schema

  def status_new, do: "new"
  def status_assigned, do: "assigned"
  def status_done, do: "done"

  schema "tasks" do
    belongs_to :driver, Db.User
    field :description, :string
    field :status, :string
    field :lat1, :float
    field :long1, :float
    field :lat2, :float
    field :long2, :float

    timestamps()
  end
end
