defmodule Db.Seed do
  def run do
    Application.load(:db)
    Ecto.Migrator.with_repo(Db.Repo, fn _repo ->
      create_user_with_token(Db.role_driver)
      create_user_with_token(Db.role_manager)
    end)
  end

  defp create_user_with_token(role) do
    {:ok, %{id: token_id, token: token}} = Db.create_token(role)
    {:ok, %{id: user_id}} = Db.create_user(token_id)

    IO.puts "-------- #{role} --------"
    IO.puts "user_id: #{user_id}"
    IO.puts "token: #{token}"
  end
end
