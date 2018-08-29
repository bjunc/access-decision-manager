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

## Usage

### Example 1

```elixir
defmodule MyApp.Auth.FooVoter do

  @behaviour AccessDecisionManager.Voter

  def vote(user, attribute) do
    cond do
     attribute == "CREATE_FOO" ->
      if is_create_allowed(user), do: :access_granted, else: :access_denied

    true ->
      :access_abstain
    end
  end

  defp is_create_allowed(user) do
    # your permission logic goes here (db checks, etc.)
  end
end

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
defmodule MyApp.Voters.FooVoter do

  @behaviour AccessDecisionManager.Voter

  @supported_attributes [
    "CREATE_FOO",
    "UPDATE_FOO",
    "DELETE_FOO"
  ]

  def vote(user, attribute) do
    if supports(user, attribute) do
      attribute
      |> String.split("_")
      |> Enum.at(0)
      |> is_operation_allowed(user)

    else
      :access_abstain
    end
  end

  defp supports(subject, attribute) do
    supports_attr = Enum.member?(@supported_attributes, attribute)
    supports_subject = subject.__struct__ == Elixir.MyApp.Accounts.User
    supports_attr and supports_subject
  end

  defp is_operation_allowed("CREATE", user) do
    # your permission logic goes here (db checks, etc.)
    :access_denied
  end
  defp is_operation_allowed("UPDATE", user) do
    # your permission logic goes here (db checks, etc.)
    :access_granted
  end
  defp is_operation_allowed(operation, user) do
    # your permission logic goes here (db checks, etc.)
    :access_denied
  end
end

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