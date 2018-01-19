defmodule AccessDecisionManager do
  @moduledoc """
  Inspired by Symfony's Access Decision Manager, "voters" are used
  to check permissions (attributes) on a subject.

  All voters set in the config are called for every `is_granted?` call.
  If the attribute and subjects are not supported by the voter, 
  then return `:access_abstain`.

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

  @doc """
  Checks if the `attribute` is granted against the `subject`.

  Example: `%User{}` (subject) is granted `ROLE_ADMIN` (attribute)
  """
  @spec is_granted?(subject :: struct(), attribute :: String.t) :: true | false
  def is_granted?(subject, attribute) do
    is_granted?(subject, attribute, subject)
  end

  @doc """
  Checks if the `primary_subject` is granted `attribute` against the `secondary_subject`.

  Example: `%User{}` (primary subject) is granted `DELETE_COMMENTS` (attribute) on `%Blog{}` (secondary subject)
  """
  @spec is_granted?(primary_subject :: struct(), attribute :: String.t, secondary_subject :: struct()) :: true | false
  def is_granted?(primary_subject, attribute, secondary_subject) do
    opts = %{voters: Application.get_env(:access_decision_manager, :voters)}
    decide(:strategy_unanimous, opts.voters, primary_subject, attribute, secondary_subject)
  end

  # This grants access as soon as there is one voter granting access.
  defp decide(:strategy_affirmative, voters, primary_subject, attribute, secondary_subject) do
    Enum.any?(voters, fn voter -> voter.vote(primary_subject, attribute, secondary_subject) === :access_granted end)
  end

  # This only grants access once all voters grant access.
  defp decide(:strategy_unanimous, voters, primary_subject, attribute, secondary_subject) do
    !Enum.any?(voters, fn voter -> voter.vote(primary_subject, attribute, secondary_subject) === :access_denied end)
  end

  # # TODO: This grants access if there are more voters granting access than denying.
  # defp decide(:strategy_consensus, voters, primary_subject, attribute, secondary_subject) do
  # end
end