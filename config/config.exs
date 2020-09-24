# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.

# General application configuration
use Mix.Config

# Configures the endpoint
config :mux_liveview, MuxLiveviewWeb.Endpoint,
  url: [host: "localhost"],
  secret_key_base: "0xT+wQ9mJAYxqNq01LGqbN/xip1WYlYw4se1aJpfkU7fjy2Jv4+awS+bsPugwPbz",
  render_errors: [view: MuxLiveviewWeb.ErrorView, accepts: ~w(html json), layout: false],
  pubsub_server: MuxLiveview.PubSub,
  live_view: [signing_salt: "d2nwO329"]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Use Jason for JSON parsing in Phoenix
config :phoenix, :json_library, Jason

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env()}.exs"
