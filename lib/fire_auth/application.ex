defmodule FireAuth.Application do
  @moduledoc false

  use Application
  require Logger

  def start(_type, _args) do
   import Supervisor.Spec

    children = [
      worker(FireAuth.KeyServer, [])
    ]

    opts = [strategy: :one_for_one, name: FireAuth.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
