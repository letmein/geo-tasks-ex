use Mix.Config

config :db, Db.Repo,
  database: "geo_tasks_test",
  username: "postgres",
  password: "",
  hostname: "localhost",
  pool: Ecto.Adapters.SQL.Sandbox
