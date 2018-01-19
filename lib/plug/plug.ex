defmodule AccessDecisionManager.Plug do
  @moduledoc """
  
  """

  @behaviour Plug
  
  def init(opts), do: opts
  
  def call(conn, opts) do
    Plug.Conn.put_private(conn, :access_decision_manager_voters, opts[:voters])
  end
end