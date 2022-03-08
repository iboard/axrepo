defmodule Altex.Repo.Gateway.DETS do
  @moduledoc ~s"""
  Implements a `Altex.Repo.Gateway` for `:dets`. where all tables are stored
  to `data/ENV/tablename.ets`. ENV will be replaced with the environment from
  `MIX_ENV`, which is either :test, :dev, or :prod

      data/prod/peope.dets
      data/prod/accounts.dets
      ...
  """

  require Logger

  @data_path Application.get_env(:axrepo, :dets_path, "data/dev")

  @doc ~s"""
  Open or create the table but closes the file Immediately. Just ensure
  the file exists.
  """
  def open_table(table, cnt \\ 3)

  def open_table(table, 0) do
    Logger.error("dets table #{inspect(table)} can't be opened after 3 tries to reset")
    {:error, {:cant_open_or_reset, table}}
  end

  def open_table(table, cnt) do
    with {:ok, ets} <- open_file(table) do
      :dets.close(ets)
      ets
    else
      {:error, {:not_a_dets_file, path}} ->
        Logger.warn("Can't open dets file for #{table}, file: #{path}. Try to reset ...")
        File.cp(path, "#{path}._") 
        File.rm(path)
        open_table(table, cnt - 1)
    end
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

    if pid = GenServer.whereis(table) do
      GenServer.cast(pid, :drop!)
    end
    :ok
  end

  ############################################################################

  defp open_file(table) do
    fqp = table |> get_path() |> to_charlist()

    :dets.open_file(table, [{:file, fqp}])
  end

  defp get_path(table) do
    Path.expand("#{table}.dets", @data_path)
  end

  defp insert_entity([uuid, entity], index), do: Map.put(index, uuid, entity)
end
