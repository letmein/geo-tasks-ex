defmodule Db.Repo.Migrations.EnableEarthdistance do
  use Ecto.Migration

  def up do
    execute "CREATE EXTENSION cube"
    execute "CREATE EXTENSION earthdistance"
  end

  def down do
    execute "DROP EXTENSION earthdistance"
    execute "DROP EXTENSION cube"
  end
end
