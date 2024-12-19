defmodule AutoElixir.TestAgent do
  @moduledoc """
  A simple test agent implementation to verify the Agent behavior.
  """
  use AutoElixir.Agent

  @impl GenServer
  def init(args) do
    {:ok, %{name: args[:name] || "test_agent", count: 0}}
  end

  @impl AutoElixir.Agent
  def handle_task({:increment, amount}, state) do
    new_count = state.count + amount
    {:ok, new_count, %{state | count: new_count}}
  end

  @impl AutoElixir.Agent
  def handle_task({:get_count}, state) do
    {:ok, state.count, state}
  end

  @impl AutoElixir.Agent
  def handle_task({:error_task}, state) do
    {:error, "Error task requested", state}
  end
end
