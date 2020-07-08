defmodule Db.Token do
  use Ecto.Schema

  schema "tokens" do
    field :role, :string
    field :token, :string

    timestamps()
  end
end
