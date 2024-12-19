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
      {:langchain, path: "../langchain"},
      {:jason, "~> 1.4"},
      {:req, "~> 0.4"},
      {:ecto, "~> 3.10"},
      {:dotenv, "~> 3.0.0", only: [:dev, :test]},
      {:nx, "~> 0.7.0"}  # Required for LangChain's Bumblebee support
    ]
  end
end
