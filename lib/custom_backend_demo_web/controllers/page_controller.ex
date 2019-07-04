defmodule CustomBackendDemoWeb.PageController do
  use CustomBackendDemoWeb, :controller

  def index(conn, _params) do
    render(conn, "index.html")
  end
end
