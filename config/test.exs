use Mix.Config

config :db, Db.Repo,
  database: "geo_tasks_test",
  username: "postgres",
  password: "",
  hostname: "localhost",
  pool: Ecto.Adapters.SQL.Sandbox

# Disable db logs in test output
config :logger, level: :info
