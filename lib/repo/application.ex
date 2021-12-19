defmodule Altex.Repo.Application do
  @moduledoc false

  use Application

  alias Altex.Repo
  alias Repo.Gateway
  alias Repo.Supervisor, as: SV

  @impl true
  def start(_type, _args) do
    children = [
      Gateway,
      SV
    ]

    opts = [strategy: :one_for_one, name: SV]
    Supervisor.start_link(children, opts)
  end
end
