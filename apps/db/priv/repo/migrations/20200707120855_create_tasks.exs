defmodule Db.Repo.Migrations.CreateTasks do
  use Ecto.Migration

  def change do
    create table(:tasks) do
      add :description, :string
      add :status, :string, null: false
      add :lat1, :float, null: false
      add :long1, :float, null: false
      add :lat2, :float, null: false
      add :long2, :float, null: false
      add :driver_id, references(:users, type: :uuid)

      timestamps()
    end

    create index("tasks", [:status])
  end
end
