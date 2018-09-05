defmodule AccessDecisionManager do
  @moduledoc """
  Inspired by Symfony's Access Decision Manager, security "voters" are a granular 
  way of checking permissions (e.g. "can this specific user edit the given item?").

  For example, you may want to check if the current user (primary subject)
  can "DELETE_COMMENT" (attribute) a Blog (secondary subject).

  Or you may simply want to check if the current user (primary subject) 
  has "ROLE_ADMIN" (attribute).

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
  """

  require Logger

  @doc """
  Checks if the `attribute` is granted against the `subject`.

  Example: `%User{}` (subject) is granted `ROLE_ADMIN` (attribute)
  """
  @spec granted?(subject :: struct(), attribute :: String.t) :: true | false
  def granted?(subject, attribute) do
    granted?(subject, attribute, nil)
  end

  @doc """
  Checks if the `primary_subject` is granted `attribute` against the `secondary_subject`.

  Example: `%User{}` (primary subject) is granted `DELETE_COMMENTS` (attribute) on `%Blog{}` (secondary subject)
  """
  @spec granted?(primary_subject :: struct(), attribute :: String.t, secondary_subject :: struct()) :: true | false
  def granted?(primary_subject, attribute, secondary_subject) do
    # start = :os.system_time(unquote(:micro_seconds))
    
    voters = get_env(:voters)
    strategy = get_env(:strategy)

    decision = decide(strategy, voters, primary_subject, attribute, secondary_subject)
    
    # time_passed = :os.system_time(unquote(:micro_seconds)) - start
    # formatted_decision = if decision, do: "GRANTED", else: "DENIED"
    # Logger.debug "#{attribute}: #{formatted_decision} #{time_passed}μs"
    
    decision
  end

  # Grant access as soon as there is one voter granting access.
  defp decide(:strategy_affirmative, voters, primary_subject, attribute, secondary_subject) do
    Enum.any?(voters, fn voter ->
      voter.vote(primary_subject, attribute, secondary_subject) == :access_granted
    end)
  end

  # This only grants access if there is no voter denying access. 
  # If all voters abstained from voting, the decision is based on the 
  # `allow_if_all_abstain` config option (which defaults to false).
  #
  # Note, we call `any?` and `all?` seperately because `any?` stops the iteration 
  # at the first invocation that returns a truthy value (potential performance benefit)
  defp decide(:strategy_unanimous, voters, primary_subject, attribute, secondary_subject) do
    any_denied? = Enum.any?(voters, fn voter -> voter.vote(primary_subject, attribute, secondary_subject) == :access_denied end)
    if any_denied? do
      false
    else
      all_abstained? = Enum.all?(voters, fn voter -> voter.vote(primary_subject, attribute, secondary_subject) == :access_abstain end)
      allow_if_all_abstain? = get_env(:allow_if_all_abstain)
      if all_abstained?, do: allow_if_all_abstain?, else: true
    end
  end

  # # TODO: This grants access if there are more voters granting access than denying.
  # defp decide(:strategy_consensus, voters, primary_subject, attribute, secondary_subject) do
  # end

  # helpers for retrieving module config.
  defp get_env(:voters), do: Application.get_env(:access_decision_manager, :voters, [])
  defp get_env(:strategy), do: Application.get_env(:access_decision_manager, :strategy, :strategy_affirmative)
  defp get_env(:allow_if_all_abstain), do: Application.get_env(:access_decision_manager, :allow_if_all_abstain, false)
end