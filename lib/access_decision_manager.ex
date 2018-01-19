defmodule AccessDecisionManager do
  @moduledoc """
  Inspired by Symfony's Access Decision Manager, "voters" are used
  to check permissions (attributes) on a subject.

  All voters set in the config are called for every `is_granted?` call.
  If the attribute and subjects are not supported by the voter, 
  then return ":access_abstain".  

  There are three "strategies":

  `:unanimous` (default)
  Only grant access if none of the voters have denied access.

  `:affirmative`
  Grant access as soon as there is one voter granting access.

  `:consensus`
  Grant access if there are more voters granting access than there are denying.
  
  > The default (and only currently supported strategy) is `:unanimous`.  
  > Support for `:affirmative` and `:consensus` are TBD.

  To use in pipeline:
  ```elixir
  pipeline :foo do
    plug AccessDecisionManager.Plug, voters: [AccessDecisionManager.Voters.FooVoter]
  end
  ```
  """

  def is_granted?(current_user, attribute) do
    is_granted?(current_user, attribute, current_user)
  end

  def is_granted?(current_user, attribute, subject) do
    opts = %{voters: Application.get_env(:access_decision_manager, :voters)}
    decide(:strategy_unanimous, opts.voters, current_user, attribute, subject)
  end

  # This grants access as soon as there is one voter granting access.
  defp decide(:strategy_affirmative, voters, current_user, attribute, subject) do
    Enum.any?(voters, fn voter -> voter.vote(current_user, attribute, subject) === :access_granted end)
  end

  # This only grants access once all voters grant access.
  defp decide(:strategy_unanimous, voters, current_user, attribute, subject) do
    !Enum.any?(voters, fn voter -> voter.vote(current_user, attribute, subject) === :access_denied end)
  end

  # # TODO: This grants access if there are more voters granting access than denying.
  # defp decide(:strategy_consensus, voters, current_user, attribute, subject) do
  # end
end