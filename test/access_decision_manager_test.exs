defmodule AccessDecisionManagerTest do
  use ExUnit.Case
  doctest AccessDecisionManager

  require Logger

  import AccessDecisionManager

  alias AccessDecisionManagerTest.MockVoter.Granted, as: GrantedMock
  alias AccessDecisionManagerTest.MockVoter.Denied, as: DeniedMock
  alias AccessDecisionManagerTest.MockVoter.Abstain, as: AbstainMock

  # set initial config values
  defp put_env(voters, strategy \\ :strategy_affirmative, allow_if_abstain \\ false) do
    Application.put_env(:access_decision_manager, :voters, voters)
    Application.put_env(:access_decision_manager, :strategy, strategy)
    Application.put_env(:access_decision_manager, :allow_if_all_abstain, allow_if_abstain)
  end

  describe "strategy_affirmative" do
    test "GRANTED when [denied, granted, abstain]" do
      put_env([DeniedMock, GrantedMock, AbstainMock])
      assert granted?(%{}, "FOO", %{})
    end

    test "DENIED when [abstain, abstain, abstain]" do
      put_env([AbstainMock, AbstainMock, AbstainMock])
      assert !granted?(%{}, "FOO", %{})
    end

    test "DENIED when [abstain, denied, abstain]" do
      put_env([AbstainMock, DeniedMock, AbstainMock])
      assert !granted?(%{}, "FOO", %{})
    end
  end

  describe "strategy_unanimous" do
    test "GRANTED when [granted, granted, granted]" do
      put_env([GrantedMock, GrantedMock, GrantedMock], :strategy_unanimous)
      assert granted?(%{}, "FOO", %{})
    end

    test "DENIED when [granted, denied, granted]" do
      put_env([GrantedMock, DeniedMock, GrantedMock], :strategy_unanimous)
      assert !granted?(%{}, "FOO", %{})
    end

    test "GRANTED when [abstain, abstain, granted]" do
      put_env([AbstainMock, AbstainMock, GrantedMock], :strategy_unanimous)
      assert granted?(%{}, "FOO", %{})
    end

    test "DENIED when [abstain, abstain, abstain]" do
      put_env([AbstainMock, AbstainMock, AbstainMock], :strategy_unanimous)
      assert !granted?(%{}, "FOO", %{})
    end

    test "GRANTED when [abstain, abstain, abstain] && allow_if_abstain = true" do
      put_env([AbstainMock, AbstainMock, AbstainMock], :strategy_unanimous, true)
      assert granted?(%{}, "FOO", %{})
    end
  end

  # describe "strategy_consensus" do
  #   test "" do
  #     assert true
  #   end
  # end
end

defmodule AccessDecisionManagerTest.MockVoter.Granted do
  def vote(_, _, _), do: :access_granted
end

defmodule AccessDecisionManagerTest.MockVoter.Denied do
  def vote(_, _, _), do: :access_denied
end

defmodule AccessDecisionManagerTest.MockVoter.Abstain do
  def vote(_, _, _), do: :access_abstain
end
