defmodule AutoElixir.LLM do
  @moduledoc """
  LLM module that integrates with Google's Gemini model through LangChain.
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
  Sends a prompt to the Gemini model and returns the response.
  """
  def complete(prompt, opts \\ []) do
    config = %{
      model: opts[:model] || "gemini-pro",
      temperature: opts[:temperature] || 0.7
    }

    with {:ok, llm} <- LangChain.ChatModels.ChatGoogleAI.new(config),
         {:ok, response} <- LangChain.ChatModels.ChatGoogleAI.call(llm, prompt) do
      case response do
        %LangChain.Message{content: content} -> {:ok, content}
        _ -> {:error, "Unexpected response format"}
      end
    else
      {:error, reason} -> {:error, reason}
    end
  end

  @doc """
  Executes a chain of prompts using the Gemini model.
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
