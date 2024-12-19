defmodule AutoElixir.LLMTest do
  use ExUnit.Case
  alias AutoElixir.LLM

  describe "format_prompt/2" do
    test "formats a simple prompt with variables" do
      template = "Hello, {{name}}! How are you feeling today, {{emotion}}?"
      variables = %{name: "Alice", emotion: "happy"}

      {:ok, result} = LLM.format_prompt(template, variables)
      assert result == "Hello, Alice! How are you feeling today, happy?"
    end

    test "returns error with missing variables" do
      template = "Hello, {{missing}}!"
      variables = %{}

      {:error, _reason} = LLM.format_prompt(template, variables)
    end
  end

  describe "complete/2" do
    test "generates mock response from prompt" do
      prompt = "Write a haiku about programming"
      {:ok, response} = LLM.complete(prompt)
      assert response == "Response to: Write a haiku about programming"
    end

    test "handles options without error" do
      prompt = "test prompt"
      {:ok, response} = LLM.complete(prompt, model: "test-model")
      assert response == "Response to: test prompt"
    end
  end

  describe "execute_chain/2" do
    test "executes a simple chain successfully" do
      steps = [
        {"Write a story about {{topic}}", fn response, vars ->
          {:ok, Map.put(vars, :story, response)}
        end},
        {"Summarize this story: {{story}}", fn response, vars ->
          {:ok, Map.put(vars, :summary, response)}
        end}
      ]

      initial_vars = %{topic: "robots"}
      {:ok, final_vars} = LLM.execute_chain(steps, initial_vars)
      
      assert final_vars.story == "Response to: Write a story about robots"
      assert final_vars.summary == "Response to: Summarize this story: Response to: Write a story about robots"
    end

    test "halts chain on format error" do
      steps = [
        {"Write about {{missing}}", fn _response, vars -> {:ok, vars} end}
      ]

      assert {:error, _reason} = LLM.execute_chain(steps, %{})
    end
  end
end
