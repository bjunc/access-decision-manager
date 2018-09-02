# Access Decision Manager

[![Hex.pm Version](https://img.shields.io/hexpm/v/access_decision_manager.svg)](https://hex.pm/packages/access_decision_manager)
[![Documentation](https://img.shields.io/badge/docs-latest-blue.svg)](https://hexdocs.pm/access_decision_manager/)

Voter based authorization for Elixir, inspired by Symfony.

## Installation

The package can be installed by adding `access_decision_manager` 
to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:access_decision_manager, "~> 0.2.0"}
    # {:access_decision_manager, git: "https://github.com/bjunc/access-decision-manager.git"}
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

## Usage

### Example 1

```elixir
defmodule MyApp.Auth.FooVoter do

  @behaviour AccessDecisionManager.Voter

  @doc """
  Is the %User{} allowed to create %Foo{}?
  """
  def vote(user, attribute, nil) do
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

```elixir
defmodule MyAppWeb.FooController do
  def create_foo(conn) do
    if AccessDecisionManager.granted?(conn.assigns.current_user, "CREATE_FOO") do
      # permission granted, create some foo
    else
      # permission denied, no foo for you
    end
  end
end
```

### Example 2

```elixir
defmodule MyApp.Auth.FooVoter do

  alias MyApp.User
  alias MyApp.Foo
  alias MyApp.Bar

  @behaviour AccessDecisionManager.Voter

  @supported_attributes [
    "CREATE_BAR",
    "UPDATE_BAR",
    "DELETE_BAR"
  ]

  @doc """
  Is the %User{} allowed to CRUD %Bar{} on %Foo{}?
  """
  def vote(%User{} = user, attribute, %Foo{} = foo) when attribute in @supported_attributes do
    op_allowed(user, attribute, foo)
  end
  def vote(_primary_subject, _attribute, _secondary_subject), do: :access_abstain

  defp op_allowed(%User{} = user, "CREATE_BAR", %Foo{} = foo) do
    # your permission logic goes here (db checks, etc.)
    :access_granted
  end
  defp op_allowed(%User{} = user, "UPDATE_BAR", %Foo{} = foo) do
    # your permission logic goes here (db checks, etc.)
    :access_granted
  end
  defp op_allowed(%User{} = user, "DELETE_BAR", %Foo{} = foo) do
    # your permission logic goes here (db checks, etc.)
    :access_denied
  end
end
```

```elixir
defmodule MyAppWeb.BarController do

  import AccessDecisionManager

  alias MyApp.Foo

  def create_bar(conn,  %{"foo_id" => foo_id}) do
    foo = Repo.get(Foo, foo_id)
    if granted?(conn.assigns.current_user, "CREATE_BAR", foo) do
      # permission granted, create some foo.bar
    else
      # permission denied, no foo.bar for you
    end
  end
end
```