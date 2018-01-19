defmodule AccessDecisionManager.Voter do
  @moduledoc """
  Voters implement the Voter behavior, which means they have to implement a 
  `vote` function to allow the decision manager to use them.
  """

  @doc """
  This method will do the actual voting. 
  
  One of the following atoms must returned: 

  * `:access_granted`
  * `:access_denied`
  * `:access_abstain`

  ## Examples
  Check a user's permission to edit a blog post:

  `vote(current_user, "EDIT", blog)`

  Check a user's permission to delete a blog post's comments

  `vote(current_user, "DELETE_COMMENTS", blog)`

  Check if a user has a particular role:

  `vote(current_user, "ROLE_ADMIN", current_user)`

  > The attribute names are entirely arbitrary.  Make them up to suit your needs!
  """
  @callback vote(subject :: struct(), attribute :: String.t, subject :: struct()) :: :access_granted | :access_denied | :access_abstain
end