defmodule Db.User do
  use Ecto.Schema

  @primary_key {:id, :binary_id, autogenerate: true}

  schema "users" do
    belongs_to :token, Db.Token

    timestamps()
  end
end
