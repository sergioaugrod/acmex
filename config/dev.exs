use Mix.Config

config :acmex,
  directory_url: System.get_env("ACMEX_DIRECTORY_URL") || "https://localhost:14000/dir",
  hackney_opts: [:insecure]
