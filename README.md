# AccessDecisionManager

Voter based authorization for Elixir, inspired by Symfony.

## Installation

The package can be installed by adding `access_decision_manager` 
to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:access_decision_manager, git: "https://github.com/bjunc/access-decision-manager.git"}
  ]
end
```

Add your configuration

```elixir
# Access Decision Manager (permission voting)
config :access_decision_manager,
  voters: [
    MyApp.Voters.FooVoter,
    MyApp.Voters.BarVoter,
  ]
```

## Basics

```elixir
defmodule MyApp.Voters.FooVoter do
  def vote(user, attribute) do
    cond do
     attribute == "CREATE_FOO" ->
      is_foo_allowed = ...
      if is_foo_allowed, do: :access_granted, else: :access_denied
      
    true ->
      :access_abstain
    end
  end
end

defmodule MyAppWeb.FooController do
  def create_foo(conn) do
    if AccessDecisionManager.is_granted?(conn.assigns.current_user, "CREATE_FOO") do
      # permission granted, create some foo
    else
      # permission denied, no foo for you
    end
  end
end
```
