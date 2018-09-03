# Getting Started

## Config

In `config.exs`

```elixir
# Access Decision Manager (permission voting)
config :access_decision_manager,
  voters: [MyApp.Auth.FooVoter]
```

## Voter

```elixir
defmodule MyApp.Auth.FooVoter do

  alias MyApp.User

  @behaviour AccessDecisionManager.Voter
  
  @supported_attributes [
    "CREATE_FOO",
    "UPDATE_FOO",
    "DELETE_FOO"
  ]

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
    :access_granted
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
