defmodule AutoElixir.MixProject do
  use Mix.Project

  def project do
    [
      app: :auto_elixir,
      version: "0.1.0",
      elixir: "~> 1.14",
      start_permanent: Mix.env() == :prod,
      deps: deps()
    ]
  end

  def application do
    [
      extra_applications: [:logger],
      mod: {AutoElixir.Application, []}
    ]
  end

  defp deps do
    [
      {:langchain, git: "https://github.com/brainlid/langchain.git"},
      {:jason, "~> 1.4"},
      {:req, "~> 0.5"},
      {:ecto, "~> 3.10"}
    ]
  end
end
