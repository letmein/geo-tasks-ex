use Mix.Config

config :db, Db.Repo,
  database: "geo_tasks",
  username: "postgres",
  password: "",
  hostname: "localhost",
  pool: Ecto.Adapters.SQL.Sandbox
