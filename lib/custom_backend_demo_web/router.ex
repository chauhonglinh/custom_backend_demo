defmodule CustomBackendDemoWeb.Router do
  use CustomBackendDemoWeb, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_flash
    plug :protect_from_forgery
    plug :put_secure_browser_headers
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/", CustomBackendDemoWeb do
    pipe_through :browser

    get "/", PageController, :index
  end

  # Other scopes may use custom stacks.
  scope "/api", CustomBackendDemoWeb do
    pipe_through :api

    # Must pipe json via :api
    resources "/users", UserController
  end
end
