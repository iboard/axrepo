defmodule Altex.Repo do
  @moduledoc ~s"""
  The Repo API has a function `start_repo/1` to start a repo server.
  The `start_repo/2` function with the 2nd parameter `:drop!` deletes
  the entire table before re-opening it. The 2nd version is used mostly in
  tests.
  """

  alias Altex.Repo.{
    Server,
    Gateway
  }

  alias Altex.Repo.Supervisor, as: SV

  @doc ~s"""
  Start the server and drop all data.
  """
  def start_repo(store, :drop!) when is_atom(store) do
    Gateway.drop!(store)
    start_repo(store)
  end

  @doc ~s"""
  Start the server for the named `store`
  """
  def start_repo(store) when is_atom(store) do
    SV.start_child(store)
  end

  @doc ~s"""
  Load the `Altex.Entity` with the id `uuid` from `store`.
  Returns `:not_found` if `uuid` doesn't exist.
  """
  defdelegate load(store, uuid), to: Server

  @doc ~s"""
  Store the given `entity` (`Altex.Entity`) to the named `store`.
  """
  defdelegate store(entity, store), to: Server

  @doc ~s"""
  Returns a list of all `Altex.Entity`s from the named `store`.
  """
  defdelegate list(store), to: Server

  @doc """
  Find an entity where the given field is equal to the
  example.
  """
  defdelegate find_by(example, field), to: Server
  defdelegate find_by(type, example, field), to: Server

  defdelegate drop!(store), to: Server
end
