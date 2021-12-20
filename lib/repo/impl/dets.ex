defmodule Altex.Repo.Gateway.DETS do
  @moduledoc ~s"""
  Implements a `Altex.Repo.Gateway` for `:dets`. where all tables are stored
  to `data/ENV/tablename.ets`. ENV will be replaced with the environment from
  `MIX_ENV`, which is either :test, :dev, or :prod

      data/prod/peope.dets
      data/prod/accounts.dets
      ...
  """

  @doc ~s"""
  Open or create the table but closes the file Immediately. Just ensure
  the file exists.
  """
  def open_table(table) do
    {:ok, ets} = open_file(table)
    :dets.close(ets)
    ets
  end

  @doc ~s"""
  Load the given `table` and return a list of all `Altex.Entity`s
  """
  def load_table(table) do
    {:ok, ets} = open_file(table)

    entities =
      ets
      |> :dets.match({:"$1", :"$2"})
      |> Enum.reduce(%{}, &insert_entity/2)

    :dets.close(ets)

    entities
  end

  @doc ~s"""
  Insert the given `entity` with the given `uuid` into `table` and returns
  the entity.
  """
  def insert(table, {uuid, entity}) do
    {:ok, ets} = open_file(table)
    :dets.insert(ets, {uuid, entity})
    :dets.close(ets)
    entity
  end

  @doc ~s"""
  Drops the entire file from disk. Mostly used in tests.
  """
  def drop!(table) do
    table
    |> get_path()
    |> File.rm()

    :ok
  end

  ############################################################################

  defp open_file(table) do
    fqp = table |> get_path() |> to_charlist()

    {:ok, _ets} = :dets.open_file(table, [{:file, fqp}])
  end

  defp get_path(table) do
    dir = Path.expand(System.get_env("MIX_ENV") || "test", "./data")

    Path.expand("#{table}.dets", dir)
  end

  defp insert_entity([uuid, entity], index), do: Map.put(index, uuid, entity)
end