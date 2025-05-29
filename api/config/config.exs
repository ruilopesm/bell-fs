# This file is responsible for configuring your application
# and its dependencies with the aid of the Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.

# General application configuration
import Config

config :pythonx, :uv_init,
  pyproject_toml: """
  [project]
  name = "bell_fs"
  version = "0.1.0"
  requires-python = "==3.13.*"
  dependencies = [
    "cryptography==44.0.3"
  ]
  """

config :bell_fs,
  ecto_repos: [BellFS.Repo],
  generators: [timestamp_type: :utc_datetime, binary_id: true]

# Configures the endpoint
config :bell_fs, BellFSWeb.Endpoint,
  url: [host: "localhost"],
  adapter: Bandit.PhoenixAdapter,
  render_errors: [
    formats: [json: BellFSWeb.ErrorJSON],
    layout: false
  ],
  pubsub_server: BellFS.PubSub,
  live_view: [signing_salt: "p/WkG5Xa"]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Use Jason for JSON parsing in Phoenix
config :phoenix, :json_library, Jason

# Configures GuardianDB for storing refresh tokens
config :guardian, Guardian.DB,
  repo: BellFS.Repo,
  schema_name: "guardian_tokens",
  token_types: ["refresh"]

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{config_env()}.exs"
