defmodule Altex.Repo.Supervisor do
  @doc ~s"""
  The `DynamicSupervisor` handles `Altex.Repo.Server`s as children and a
  `:one_for_one` strategy.
  """

  use DynamicSupervisor

  alias Altex.Repo.{
    Server
  }

  @doc false
  def start_link(_init_arg \\ []) do
    DynamicSupervisor.start_link(__MODULE__, :ok, name: :repo_supervisor)
  end

  @impl true
  def init(_init_arg) do
    DynamicSupervisor.init(strategy: :one_for_one)
  end

  @doc ~s"""
  Starts and supervises a `Altex.Repo.Supervisor` for the named `store`.
  """
  def start_child(store) when is_atom(store) do
    spec = %{id: Server, start: {Server, :start_link, [store]}}
    DynamicSupervisor.start_child(:repo_supervisor, spec)
  end
end
