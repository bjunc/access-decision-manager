defmodule AccessDecisionManager do
  @moduledoc """
  Inspired by Symfony's Access Decision Manager, "voters" are used
  to check permissions (attributes) on a subject.

  For example, you may want to check if the current user (primary subject)
  can "DELETE_COMMENT" (attribute) a Blog (secondary subject).

  Or you may simply want to check if the current user (primary subject) 
  has "ROLE_ADMIN" (attribute).

  There are three "strategies":

  `:strategy_affirmative` (default)
  Grant access as soon as there is one voter granting access.

  `:strategy_consensus`
  Grant access if there are more voters granting access than there are denying.

  `:strategy_unanimous`
  Only grant access if none of the voters have denied access.
  
  > The default (and only currently supported strategy) is `:strategy_affirmative`.  
  > Support for `:strategy_unanimous` and `:strategy_consensus` are TBD.

  To use in pipeline:
  ```elixir
  pipeline :foo do
    plug AccessDecisionManager.Plug, voters: [MyApp.Auth.FooVoter]
  end
  ```
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
    
    opts = %{voters: Application.get_env(:access_decision_manager, :voters)}
    decision = decide(:strategy_affirmative, opts.voters, primary_subject, attribute, secondary_subject)
    
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

  # Only grant access if none of the voters have denied access.
  defp decide(:strategy_unanimous, voters, primary_subject, attribute, secondary_subject) do
    !Enum.any?(voters, fn voter -> voter.vote(primary_subject, attribute, secondary_subject) === :access_denied end)
  end

  # # TODO: This grants access if there are more voters granting access than denying.
  # defp decide(:strategy_consensus, voters, primary_subject, attribute, secondary_subject) do
  # end
end