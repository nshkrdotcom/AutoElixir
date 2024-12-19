import Config

# Use mock LLM in test environment
config :auto_elixir, :llm_module, AutoElixir.MockLLM
