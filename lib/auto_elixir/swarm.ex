defmodule AutoElixir.Swarm do
  @moduledoc """
  Manages a collection of agents and coordinates task distribution among them.
  """
  use GenServer

  # Client API

  def start_link(agent_specs) do
    GenServer.start_link(__MODULE__, agent_specs)
  end

  def assign_task(swarm, task) do
    GenServer.call(swarm, {:assign_task, task})
  end

  # Server Callbacks

  def init(agent_specs) do
    # Start each agent and store their PIDs
    agents =
      Enum.map(agent_specs, fn spec ->
        {:ok, pid} = apply(spec.module, :start_link, [spec.args])
        {spec.name, pid}
      end)
      |> Map.new()

    {:ok, %{agents: agents, current_index: 0}}
  end

  def handle_call({:assign_task, task}, _from, state) do
    # Simple round-robin task assignment
    agent_names = Map.keys(state.agents)
    next_index = rem(state.current_index + 1, length(agent_names))
    
    case Enum.at(agent_names, state.current_index) do
      nil ->
        {:reply, {:error, :no_agents}, state}
      agent_name ->
        agent_pid = state.agents[agent_name]
        result = AutoElixir.Agent.execute_task(agent_pid, task)
        {:reply, result, %{state | current_index: next_index}}
    end
  end
end
