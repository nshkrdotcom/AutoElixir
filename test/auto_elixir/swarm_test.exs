defmodule AutoElixir.SwarmTest do
  use ExUnit.Case
  alias AutoElixir.{Swarm, TestAgent}

  describe "Swarm" do
    test "creates a swarm with multiple agents" do
      agent_specs = [
        %{name: :agent1, module: TestAgent, args: [name: "agent1"]},
        %{name: :agent2, module: TestAgent, args: [name: "agent2"]}
      ]

      {:ok, swarm} = Swarm.start_link(agent_specs)
      assert is_pid(swarm)
    end

    test "assigns tasks in round-robin fashion" do
      agent_specs = [
        %{name: :agent1, module: TestAgent, args: [name: "agent1"]},
        %{name: :agent2, module: TestAgent, args: [name: "agent2"]}
      ]

      {:ok, swarm} = Swarm.start_link(agent_specs)
      
      # First task should go to agent1
      assert {:ok, 5} = Swarm.assign_task(swarm, {:increment, 5})
      
      # Second task should go to agent2
      assert {:ok, 3} = Swarm.assign_task(swarm, {:increment, 3})
      
      # Third task should go back to agent1
      assert {:ok, 10} = Swarm.assign_task(swarm, {:increment, 5})
    end

    test "handles errors from agents" do
      agent_specs = [
        %{name: :agent1, module: TestAgent, args: [name: "agent1"]}
      ]

      {:ok, swarm} = Swarm.start_link(agent_specs)
      assert {:error, "Error task requested"} = Swarm.assign_task(swarm, {:error_task})
    end
  end
end
