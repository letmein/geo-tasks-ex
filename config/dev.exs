use Mix.Config

config :db, Db.Repo,
  database: "geo_tasks_dev",
  username: "postgres",
  password: "",
  hostname: "localhost"
