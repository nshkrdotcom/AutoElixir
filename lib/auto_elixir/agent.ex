defmodule AutoElixir.Agent do
  @moduledoc """
  Defines the base behavior for all agents in the AutoElixir system.
  
  An agent is a long-running process that can handle tasks and maintain state.
  Agents can communicate with each other and access shared knowledge.
  """

  @doc """
  Callback invoked to handle a task.
  Takes the task and current state, returns the result and new state.
  """
  @callback handle_task(task :: term, state :: term) :: 
    {:ok, result :: term, new_state :: term} | 
    {:error, reason :: term, state :: term}

  @doc """
  Executes a task on the given agent.
  """
  def execute_task(pid, task) do
    GenServer.call(pid, {:task, task})
  end

  @doc """
  Provides common agent functionality when used.
  Sets up the agent as a GenServer with standard behavior.
  """
  defmacro __using__(_opts) do
    quote do
      @behaviour AutoElixir.Agent
      use GenServer

      def start_link(args) do
        GenServer.start_link(__MODULE__, args)
      end

      @impl GenServer
      def handle_call({:task, task}, _from, state) do
        case __MODULE__.handle_task(task, state) do
          {:ok, result, new_state} -> {:reply, {:ok, result}, new_state}
          {:error, reason, state} -> {:reply, {:error, reason}, state}
        end
      end

      @impl AutoElixir.Agent
      def handle_task(_task, state), do: {:ok, :ok, state}

      defoverridable [handle_task: 2]
    end
  end
end
