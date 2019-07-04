defmodule CustomBackendDemo.Repo do
  use Ecto.Repo,
    otp_app: :custom_backend_demo,
    adapter: Ecto.Adapters.Postgres
end
