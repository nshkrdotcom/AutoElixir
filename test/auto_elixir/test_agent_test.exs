defmodule AutoElixir.TestAgentTest do
  use ExUnit.Case
  alias AutoElixir.{Agent, TestAgent}

  describe "TestAgent" do
    test "starts with initial state" do
      {:ok, pid} = TestAgent.start_link(name: "counter")
      assert {:ok, 0} = Agent.execute_task(pid, {:get_count})
    end

    test "can increment counter" do
      {:ok, pid} = TestAgent.start_link(name: "counter")
      assert {:ok, 5} = Agent.execute_task(pid, {:increment, 5})
      assert {:ok, 5} = Agent.execute_task(pid, {:get_count})
    end

    test "handles error tasks" do
      {:ok, pid} = TestAgent.start_link(name: "counter")
      assert {:error, "Error task requested"} = Agent.execute_task(pid, {:error_task})
      # State should remain unchanged after error
      assert {:ok, 0} = Agent.execute_task(pid, {:get_count})
    end
  end
end
