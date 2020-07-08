defmodule Db.Repo.Migrations.CreateTokens do
  use Ecto.Migration

  def change do
    create table(:tokens) do
      add :role, :string, null: false
      add :token, :string, null: false

      timestamps()
    end

    create index("tokens", [:token], unique: true)
    create index("tokens", [:token, :role])
  end
end
