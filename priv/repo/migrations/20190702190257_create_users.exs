defmodule CustomBackendDemo.Repo.Migrations.CreateUsers do
  use Ecto.Migration

  def change do
    create table(:users) do
      add :username, :string
      add :email, :string
      add :first_name, :string
      add :last_name, :string
      add :birthdate, :date

      timestamps()
    end

  end
end
