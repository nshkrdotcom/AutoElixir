defmodule AutoElixir do
  @moduledoc """
  AutoElixir is a multi-agent AI framework built on BEAM.
  
  It provides a simple interface to create and manage AI agents that can work together
  to accomplish complex tasks. Built on top of LangChain, it leverages the BEAM's
  concurrency model for efficient agent communication and task execution.

  ## Example Usage in Phoenix

      # In your Phoenix application
      defmodule MyApp.AIManager do
        use AutoElixir.Agent
        
        def start_task(task) do
          AutoElixir.create_swarm([
            {:researcher, AutoElixir.Agents.Researcher},
            {:writer, AutoElixir.Agents.Writer},
            {:reviewer, AutoElixir.Agents.Reviewer}
          ])
          |> AutoElixir.assign_task(task)
        end
      end
  """

  @doc """
  Creates a new swarm of agents that can work together.
  """
  @spec create_swarm(agent_specs :: [{atom(), module()}]) :: {:ok, pid()} | {:error, term()}
  def create_swarm(agent_specs) do
    AutoElixir.Swarm.start_link(agent_specs)
  end

  @doc """
  Assigns a task to a swarm of agents.
  """
  @spec assign_task(swarm :: pid(), task :: term()) :: {:ok, reference()} | {:error, term()}
  def assign_task(swarm, task) do
    AutoElixir.Swarm.assign_task(swarm, task)
  end
end
