use Mix.Config

# Configure your database
config :custom_backend_demo, CustomBackendDemo.Repo,
  username: "postgres",
  password: "postgres",
  database: "custom_backend_demo_test",
  hostname: "localhost",
  pool: Ecto.Adapters.SQL.Sandbox

# We don't run a server during test. If one is required,
# you can enable the server option below.
config :custom_backend_demo, CustomBackendDemoWeb.Endpoint,
  http: [port: 4002],
  server: false

config :logger,
  backends: [{CustomBackendDemo.ProxyBackend, :proxy_log}],
  level: :warn

config :logger, :proxy_log,
  backend_list: [
    %{
      module: LoggerFileBackend,
      backend_type: :only_phi,
      name: :only_phi_log,
      init_params: {LoggerFileBackend, :only_phi_log}
    },
    %{
      module: LoggerFileBackend,
      backend_type: :all_no_phi,
      name: :all_no_phi_log,
      init_params: {LoggerFileBackend, :all_no_phi_log}
    },
    %{
      module: LoggerFileBackend,
      backend_type: :all,
      name: :all_log,
      init_params: {LoggerFileBackend, :all_log}
    }
  ]

config :logger, :only_phi_log,
  path: "./tmp/only_phi.log",
  level: :debug

config :logger, :all_no_phi_log,
  path: "./tmp/all_no_phi.log",
  level: :debug

config :logger, :all_log,
  path: "./tmp/all.log",
  level: :debug
