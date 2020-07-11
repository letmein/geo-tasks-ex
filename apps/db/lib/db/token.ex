defmodule Db.Token do
  use Ecto.Schema

  def role_manager, do: "manager"
  def role_driver, do: "driver"

  schema "tokens" do
    field :role, :string
    field :token, :string

    timestamps()
  end
end
