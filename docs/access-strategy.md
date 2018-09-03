# Access Strategy

All voters are called each time you use the `granted?()` function.  
AccessDecisionManager then takes the responses from all voters and makes 
the final decision (to allow or deny access to the resource) according 
to the strategy defined.

There are three "strategies":

`:strategy_affirmative` (default)  
This grants access as soon as there is one voter granting access.

`:strategy_consensus`
This grants access if there are more voters granting access than denying.

`:strategy_unanimous`
This only grants access if there is no voter denying access. 
If all voters abstained from voting, the decision is based on the 
`allow_if_all_abstain` config option (which defaults to false).

> The default (and only currently supported strategy) is `:strategy_affirmative`.  
> Support for `:strategy_unanimous` and `:strategy_consensus` are TBD.

### Changing the Access Decision Strategy

Normally, only one voter will vote at any given time (the rest will "abstain", which means they return `:access_abstain`). But in theory, you could make multiple voters vote for one attribute and subject. For instance, suppose you have one voter that checks if the user is a member of the site and a second one that checks if the user is older than 18.

In the above scenario, both voters should grant access in order to grant access to the user to read the post. In this case, the default strategy is no longer valid and `:strategy_unanimous` should be used instead. You can set this in the security configuration:

```elixir
# config.exs
config :access_decision_manager,
  voters: [MyApp.Auth.FooVoter],
  strategy: :strategy_unanimous,
  allow_if_all_abstain: false

```
