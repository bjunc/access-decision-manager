# Getting Started

## Config

```elixir
# Access Decision Manager (permission voting)
config :access_decision_manager,
  voters: [MyApp.Auth.FooVoter]
```

## Voter
```elixir
defmodule MyApp.Auth.FooVoter do

  @behaviour AccessDecisionManager.Voter

  def vote(user, attribute) do
    cond do
     attribute == "CREATE_FOO" ->
      if create_allowed?(user), do: :access_granted, else: :access_denied

    true ->
      :access_abstain
    end
  end

  defp create_allowed?(user) do
    # your permission logic goes here (db checks, etc.)
  end
end
```

## Controller
```elixir
defmodule MyAppWeb.FooController do

  import AccessDecisionManager

  def create_foo(conn) do
    if granted?(conn.assigns.current_user, "CREATE_FOO") do
      # permission granted, create some foo
    else
      # permission denied, no foo for you
    end
  end
end
```