defmodule CustomBackendDemoWeb.UserView do
  use CustomBackendDemoWeb, :view
  alias CustomBackendDemoWeb.UserView

  def render("index.json", %{users: users}) do
    %{data: render_many(users, UserView, "user.json")}
  end

  def render("show.json", %{user: user}) do
    %{data: render_one(user, UserView, "user.json")}
  end

  def render("user.json", %{user: user}) do
    %{id: user.id,
      username: user.username,
      email: user.email,
      first_name: user.first_name,
      last_name: user.last_name,
      birthdate: user.birthdate}
  end
end
