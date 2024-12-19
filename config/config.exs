import Config

config :langchain,
  google_ai: [
    api_key: System.get_env("GOOGLE_API_KEY")
  ]

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
if File.exists?("config/#{config_env()}.exs") do
  import_config "#{config_env()}.exs"
end
