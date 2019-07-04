# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.

# General application configuration
use Mix.Config

config :custom_backend_demo,
  ecto_repos: [CustomBackendDemo.Repo]

# Configures the endpoint
config :custom_backend_demo, CustomBackendDemoWeb.Endpoint,
  url: [host: "localhost"],
  secret_key_base: "Be/dja2itfarilY8g6JqIfzrJnnLsFgCqFLzeYPQFc3q/YiqcgaPwoKBgon1hdf9",
  render_errors: [view: CustomBackendDemoWeb.ErrorView, accepts: ~w(html json)],
  pubsub: [name: CustomBackendDemo.PubSub, adapter: Phoenix.PubSub.PG2]


# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Use Jason for JSON parsing in Phoenix
config :phoenix, :json_library, Jason

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env()}.exs"
