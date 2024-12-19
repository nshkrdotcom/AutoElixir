defmodule AutoElixir.MockLLM do
  @moduledoc """
  Mock LLM module for testing the agent framework.
  """

  @doc """
  Formats a prompt using simple string interpolation.
  """
  def format_prompt(template, variables) do
    # First find all variables in the template
    vars_needed = Regex.scan(~r/\{\{(\w+)\}\}/, template)
                 |> Enum.map(fn [_, var] -> var end)
                 |> MapSet.new()
    
    # Convert atom keys to strings for comparison
    vars_provided = variables 
                   |> Map.keys() 
                   |> Enum.map(&to_string/1)
                   |> MapSet.new()
    
    missing_vars = MapSet.difference(vars_needed, vars_provided)
    
    if MapSet.size(missing_vars) > 0 do
      {:error, "Missing variables: #{Enum.join(missing_vars, ", ")}"}
    else
      try do
        result = Enum.reduce(variables, template, fn {key, value}, acc ->
          String.replace(acc, "{{#{to_string(key)}}}", to_string(value))
        end)
        {:ok, result}
      rescue
        e -> {:error, "Failed to format prompt: #{Exception.message(e)}"}
      end
    end
  end

  @doc """
  Mock LLM completion that returns predefined responses for testing.
  """
  def complete(prompt, _opts \\ []) do
    # For testing, just echo back the prompt
    {:ok, "Response to: " <> prompt}
  end

  @doc """
  Executes a chain of prompts using mock responses.
  """
  def execute_chain(steps, initial_vars) do
    steps
    |> Enum.reduce_while({:ok, initial_vars}, fn {template, var_fn}, {:ok, vars} ->
      with {:ok, prompt} <- format_prompt(template, vars),
           {:ok, response} <- complete(prompt),
           {:ok, new_vars} <- var_fn.(response, vars) do
        {:cont, {:ok, new_vars}}
      else
        {:error, reason} -> {:halt, {:error, reason}}
      end
    end)
  end
end
