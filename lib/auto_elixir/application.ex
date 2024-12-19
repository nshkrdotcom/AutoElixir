defmodule AutoElixir.Application do
  @moduledoc false
  use Application

  @impl true
  def start(_type, _args) do
    children = [
      # Add your supervisors and workers here
    ]

    opts = [strategy: :one_for_one, name: AutoElixir.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
