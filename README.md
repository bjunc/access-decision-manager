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
    {:access_decision_manager, "~> 0.2.1"}
  ]
end
```

Add your configuration

```elixir
# Access Decision Manager (permission voting)
config :access_decision_manager,
  voters: [
    MyApp.Auth.FooVoter,
    MyApp.Auth.BarVoter,
  ]
```

## Usage

Security voters are a granular way of checking permissions (e.g. "can this specific user edit the given item?").

All voters are called each time you use the`granted?()` function.  AccessDecisionManager then takes the responses from all voters and makes the final decision (to allow or deny access to the resource) according to the strategy defined, which can be: `:strategy_affirmative`, `:strategy_consensus` or `:strategy_unanimous`.


A custom voter needs to implement the `AccessDecisionManager.Voter` behavior:

```elixir
defmodule Mypp.Auth.FooVoter do
  @behaviour AccessDecisionManager.Voter
  def vote(_primary_subject, _attribute, _secondary_subject), do :access_abstain
end
```

> Important: since _every_ voter is called, _every_ voter must return a decision.  If the attribute and subjects do not apply to the voter, then abstain from voting by returning `:access_abstain`.
 

#### Example 1

```elixir
defmodule MyApp.Auth.FooVoter do

  @behaviour AccessDecisionManager.Voter
  
  alias MyApp.User

  @doc """
  Is the %User{} allowed to create %Foo{}?
  """
  def vote(%User{} = user, "CREATE_FOO", nil) do
    if create_allowed?(user), do: :access_granted, else: :access_denied
  end
  def vote(_primary_subject, _attribute, _secondary_user), do: :access_abstain

  defp create_allowed?(user) do
    # your permission logic goes here (db checks, etc.)
  end
end
```

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

#### Example 2

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

### Changing the Access Decision Strategy

Normally, only one voter will vote at any given time (the rest will "abstain", which means they return `:access_abstain`). But in theory, you could make multiple voters vote for one attribute and subject. For instance, suppose you have one voter that checks if the user is a member of the site and a second one that checks if the user is older than 18.

To handle these cases, the access decision manager uses an access decision strategy. You can configure this to suit your needs. There are three strategies available:

`:strategy_affirmative` (default)  
This grants access as soon as there is one voter granting access.

`:strategy_consensus`  
This grants access if there are more voters granting access than denying.

`:strategy_unanimous`  
This only grants access if there is no voter denying access. If all voters abstained from voting, the decision is based on the `allow_if_all_abstain` config option (which defaults to false).

> The default (and only currently supported strategy) is `:strategy_affirmative`.  
> Support for `:strategy_consensus` is TBD.

In the above scenario, both voters should grant access in order to grant access to the user to read the post. In this case, the default strategy is no longer valid and `:strategy_unanimous` should be used instead. You can set this in the security configuration:

```elixir
# config.exs
config :access_decision_manager,
  voters: [MyApp.Auth.FooVoter],
  strategy: :strategy_unanimous,
  allow_if_all_abstain: false

```
