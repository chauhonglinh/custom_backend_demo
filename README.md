# CustomBackendDemo

To start your Phoenix server:

  * Install dependencies with `mix deps.get`
  * Create and migrate your database with `mix ecto.setup`
  * Install Node.js dependencies with `cd assets && npm install`
  * Start Phoenix endpoint with `mix phx.server`

Now you can visit [`localhost:4000/api/users`](http://localhost:4000/api/users) from your browser.

Ready to run in production? Please [check our deployment guides](https://hexdocs.pm/phoenix/deployment.html).

Use this code to create a user to test:
```elixir
alias CustomBackendDemo.Users
valid_attrs = %{birthdate: ~D[2010-04-17], email: "test@email.com", first_name: "John", last_name: "Smith", username: "johnsmith"}
%{} |> Enum.into(valid_attrs) |> Users.create_user()
```

## Learn more

  * Official website: http://www.phoenixframework.org/
  * Guides: https://hexdocs.pm/phoenix/overview.html
  * Docs: https://hexdocs.pm/phoenix
  * Mailing list: http://groups.google.com/group/phoenix-talk
  * Source: https://github.com/phoenixframework/phoenix
