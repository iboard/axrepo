defmodule Altex.Repo.Gateway.ETS do
  @moduledoc ~s"""
  Implements the functions `open_table/1`, `load_table/1`, `insert/2` and
  `drop!/1` of `Altex.Repo.Gateway` for _ETS_. A simple in-memory implementation.
  """

  @doc ~s"""
  Creates a new table in memory. Protected to the name process (`:repo_gateway`).
  """
  def open_table(table) do
    :ets.new(table, [:set, :protected, :named_table])
  end

  @doc ~s"""
  Return the list of all `Altex.Entity`s.
  """
  def load_table(table) do
    table
    |> :ets.match({:"$1", :"$2"})
    |> Enum.reduce(%{}, &insert_entity/2)
  end

  @doc ~s"""
  Insert `entity` with id `uuid` into `table`.
  """
  def insert(table, {uuid, entity}) do
    :ets.insert(table, {uuid, entity})
  end

  @doc ~s"""
  Drop all entities is a noop in the :ets-implementation.
  """
  def drop!(_table) do
    :noop
  end

  #############################################################################

  defp insert_entity([uuid, entity], index), do: Map.put(index, uuid, entity)
end
